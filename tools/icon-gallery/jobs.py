#!/usr/bin/env python3
"""Three prompt producers share one serial Draw Things worker."""
import argparse
import base64
import fcntl
import json
import secrets
import sqlite3
import struct
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import Request, urlopen

from common import DEFAULT_WORKSPACE, LANES, atomic_json, connect, setup


def validate_job(data):
    if not isinstance(data, dict):
        raise ValueError("JSONオブジェクトを指定してください")
    allowed = {"title", "target_id", "source_docs", "notes", "prompt", "negative_prompt", "seed", "model",
               "width", "height", "steps", "cfg_scale", "sampler_name", "clip_skip",
               "mode", "init_image", "denoising_strength"}
    if set(data) - allowed:
        raise ValueError("未対応の項目: " + ", ".join(sorted(set(data) - allowed)))
    job = {"width": 1024, "height": 1024, "steps": 25, "cfg_scale": 7.0,
           "sampler_name": "DPM++ 2M Karras", "negative_prompt": "", **data}
    if not isinstance(job.get("prompt"), str) or not job["prompt"].strip() or len(job["prompt"]) > 16000:
        raise ValueError("空でないpromptが必要です")
    if "REPLACE_WITH_" in job["prompt"]:
        raise ValueError("例のプレースホルダーを実際のプロンプトに置き換えてください")
    if not isinstance(job.get("model"), str) or not job["model"].strip():
        raise ValueError("導入済みSDXLモデルのファイル名をmodelに指定してください")
    for key in ("title", "target_id", "notes", "negative_prompt", "sampler_name"):
        if key in job and (not isinstance(job[key], str) or len(job[key]) > 16000):
            raise ValueError(key + "は文字列で指定してください")
    if "source_docs" in job and (not isinstance(job["source_docs"], list) or not all(isinstance(x, str) for x in job["source_docs"])):
        raise ValueError("source_docsはパスの配列です")
    for key in ("width", "height"):
        value = job[key]
        if type(value) is not int or not 256 <= value <= 1536 or value % 64:
            raise ValueError(key + "は256〜1536の64の倍数です")
    if type(job["steps"]) is not int or not 1 <= job["steps"] <= 80:
        raise ValueError("stepsは1〜80です")
    if type(job["cfg_scale"]) not in (int, float) or not 0 <= job["cfg_scale"] <= 30:
        raise ValueError("cfg_scaleは0〜30です")
    if "clip_skip" in job and (type(job["clip_skip"]) is not int or not 1 <= job["clip_skip"] <= 23):
        raise ValueError("clip_skipは1〜23の整数です")
    mode = job.get("mode", "txt2img")
    if mode not in ("txt2img", "img2img"):
        raise ValueError("modeはtxt2imgまたはimg2imgです")
    if mode == "img2img":
        name = job.get("init_image")
        if not isinstance(name, str) or not name or "\\" in name:
            raise ValueError("img2imgには作業領域内のinit_imageが必要です")
        parts = name.split("/")
        if len(parts) < 3 or parts[1] not in ("references", "images") or any(x in ("", ".", "..") for x in parts) or not name.lower().endswith(".png"):
            raise ValueError("init_imageは作業領域内のreferencesまたはimagesのPNGです")
        value = job.get("denoising_strength")
        if type(value) not in (int, float) or not 0 < value <= 1:
            raise ValueError("denoising_strengthは0より大きく1以下です")
    elif "init_image" in job or "denoising_strength" in job:
        raise ValueError("初期画像と強度はimg2imgで指定してください")
    seed = job.get("seed", -1)
    if type(seed) is not int or not -1 <= seed <= 4294967295:
        raise ValueError("seedが不正です")
    job["seed"] = secrets.randbelow(4294967296) if seed == -1 else seed
    return job


def enqueue(workspace, lane, data):
    job = validate_job(data)
    now = time.time()
    job_id = lane + "-" + time.strftime("%Y%m%d-%H%M%S") + "-" + secrets.token_hex(4)
    with connect(workspace) as db:
        db.execute("INSERT INTO jobs (id, lane, payload, state, created_at, updated_at) VALUES (?, ?, ?, 'queued', ?, ?)",
                   (job_id, lane, json.dumps(job, ensure_ascii=False), now, now))
    return job_id


def amend(workspace, job_id, data):
    with connect(workspace) as db:
        db.execute("BEGIN IMMEDIATE")
        row = db.execute("SELECT payload,state FROM jobs WHERE id=?", (job_id,)).fetchone()
        if not row or row["state"] != "queued":
            raise ValueError("待機中のジョブだけ変更できます")
        seed = json.loads(row["payload"])["seed"]
        job = validate_job({**data, "seed": seed})
        db.execute("UPDATE jobs SET payload=?,updated_at=? WHERE id=? AND state='queued'",
                   (json.dumps(job, ensure_ascii=False), time.time(), job_id))
    return job


def initial_image(workspace, job):
    path = workspace
    for part in job["init_image"].split("/"):
        path = path / part
        if path.is_symlink():
            raise ValueError("初期画像のシンボリックリンクは対象外です")
    raw = path.read_bytes()
    if not raw.startswith(b"\x89PNG\r\n\x1a\n") or len(raw) < 24:
        raise ValueError("初期画像はPNGで指定してください")
    if struct.unpack(">II", raw[16:24]) != (job["width"], job["height"]):
        raise ValueError("初期画像のサイズを生成サイズに合わせてください")
    return base64.b64encode(raw).decode()


def request_json(endpoint, route, payload=None, timeout=10):
    address = urlsplit(endpoint)
    if address.scheme != "http" or address.hostname not in ("127.0.0.1", "localhost", "::1"):
        raise ValueError("Draw ThingsはMac上のHTTP APIを指定してください")
    body = json.dumps(payload).encode() if payload is not None else None
    request = Request(endpoint.rstrip("/") + route, data=body,
                      headers={"Content-Type": "application/json"})
    with urlopen(request, timeout=timeout) as response:
        return json.load(response)


def claim(workspace):
    with connect(workspace) as db:
        db.execute("BEGIN IMMEDIATE")
        # FIFO lets the three producers interleave without filename collisions.
        row = db.execute("SELECT * FROM jobs WHERE state='queued' ORDER BY created_at, id LIMIT 1").fetchone()
        if row:
            db.execute("UPDATE jobs SET state='running', updated_at=? WHERE id=?", (time.time(), row["id"]))
            return dict(row)
    return None


def finish(workspace, job_id, state, error="", outputs=None):
    with connect(workspace) as db:
        db.execute("UPDATE jobs SET state=?, error=?, outputs=?, updated_at=? WHERE id=?",
                   (state, error[:2000], json.dumps(outputs or []), time.time(), job_id))


def generate(workspace, row, endpoint, timeout):
    job = validate_job(json.loads(row["payload"]))
    path = workspace / row["lane"] / "images" / (row["id"] + ".png")
    if path.exists():
        # A crash after saving an image but before updating SQLite needs no rerender.
        sidecar = json.loads(path.with_name(path.name + ".json").read_text())
        if sidecar.get("job_id") != row["id"] or sidecar.get("seed") != job["seed"]:
            raise ValueError("同名の出力が存在します。内容を確認してください")
        with path.open("rb") as stream:
            if stream.read(8) != b"\x89PNG\r\n\x1a\n":
                raise ValueError("保存済みの出力が不正です")
        return [path.relative_to(workspace).as_posix()]
    payload = {key: job[key] for key in ("prompt", "negative_prompt", "model", "seed", "width", "height",
                                        "steps", "cfg_scale", "sampler_name")}
    if "clip_skip" in job:
        payload["clip_skip"] = job["clip_skip"]
    # Explicitly disable batch/hires defaults inherited from the app UI.
    payload.update({"batch_size": 1, "n_iter": 1, "hires_fix": False, "loras": [], "controls": [],
                    "refiner_model": None, "upscaler": None, "zero_negative_prompt": False})
    route = "/sdapi/v1/txt2img"
    if job.get("mode") == "img2img":
        payload["init_images"] = [initial_image(workspace, job)]
        payload["denoising_strength"] = job["denoising_strength"]
        route = "/sdapi/v1/img2img"
    response = request_json(endpoint, route, payload, timeout)
    images = response.get("images", [])
    if not isinstance(images, list) or len(images) != 1:
        raise ValueError("Draw Thingsから1枚の画像が返りませんでした")
    outputs = []
    for index, encoded in enumerate(images):
        if not isinstance(encoded, str):
            raise ValueError("画像データが不正です")
        raw = base64.b64decode(encoded.split(",", 1)[-1], validate=True)
        if not raw.startswith(b"\x89PNG\r\n\x1a\n"):
            raise ValueError("Draw ThingsからPNG画像が返りませんでした")
        metadata = {**job, "job_id": row["id"], "backend": "draw-things-http", "created_at": time.time(),
                    "zero_negative_prompt": False}
        atomic_json(path.with_name(path.name + ".json"), metadata)
        temporary = path.with_suffix(".png.tmp")
        temporary.write_bytes(raw)
        temporary.replace(path)
        outputs.append(path.relative_to(workspace).as_posix())
    return outputs


def work(workspace, endpoint, timeout, once=False):
    # Enforce one GPU consumer even if each OpenCode session tries to start one.
    with (workspace / ".runtime" / "worker.lock").open("a+") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise ValueError("Draw Thingsワーカーはすでに起動しています")
        options = request_json(endpoint, "/sdapi/v1/options")
        if not isinstance(options, dict) or "model" not in options:
            raise ValueError("Draw ThingsのHTTP APIを確認してください")
        print("Draw Things接続済み。A/B/Cのキューを1枚ずつ生成します。", flush=True)
        while True:
            row = claim(workspace)
            if row is None:
                if once:
                    return
                time.sleep(2)
                continue
            print(row["id"] + ": generating", flush=True)
            try:
                outputs = generate(workspace, row, endpoint, timeout)
                finish(workspace, row["id"], "done", outputs=outputs)
                print(row["id"] + ": done", flush=True)
            except HTTPError as error:
                # 4xx validation errors did not generate; 5xx may have.
                state = "failed" if 400 <= error.code < 500 else "uncertain"
                detail = error.read(2048).decode(errors="replace")
                finish(workspace, row["id"], state, str(error) + " " + detail)
                print(row["id"] + ": " + state, flush=True)
                if state == "uncertain":
                    raise ValueError("結果が不明なためワーカーを停止しました。残りのキューは待機中です")
            except (URLError, TimeoutError, OSError, ValueError) as error:
                # A response timeout must never blindly re-submit expensive work.
                finish(workspace, row["id"], "uncertain", str(error))
                print(row["id"] + ": uncertain — " + str(error), flush=True)
                raise ValueError("結果が不明なためワーカーを停止しました。残りのキューは待機中です")
            except BaseException:
                finish(workspace, row["id"], "uncertain", "ワーカーが中断されました。Draw Things側を確認してください。")
                raise
            if once:
                return


def main():
    parser = argparse.ArgumentParser(description="OpenCodeの3担当用Draw Things生成キュー")
    parser.add_argument("--workspace", type=Path, default=DEFAULT_WORKSPACE)
    sub = parser.add_subparsers(dest="command", required=True)
    submit = sub.add_parser("enqueue")
    submit.add_argument("--lane", choices=LANES, required=True)
    submit.add_argument("--file", type=Path, required=True)
    modify = sub.add_parser("amend")
    modify.add_argument("--id", required=True)
    modify.add_argument("--file", type=Path, required=True)
    sub.add_parser("list")
    retry = sub.add_parser("retry")
    retry.add_argument("--id", required=True)
    recover = sub.add_parser("recover")
    recover.add_argument("--id", required=True)
    for command in ("check", "work"):
        part = sub.add_parser(command)
        part.add_argument("--url", default="http://127.0.0.1:7860")
        if command == "work":
            part.add_argument("--timeout", type=int, default=1800)
            part.add_argument("--once", action="store_true")
    args = parser.parse_args()
    workspace = setup(args.workspace)
    try:
        if args.command == "enqueue":
            print(enqueue(workspace, args.lane, json.loads(args.file.read_text())))
        elif args.command == "amend":
            amend(workspace, args.id, json.loads(args.file.read_text()))
            print(args.id + ": queued（変更済み・同じseed）")
        elif args.command == "check":
            data = request_json(args.url, "/sdapi/v1/options")
            print(json.dumps({key: data.get(key) for key in ("model", "width", "height", "steps")}, ensure_ascii=False, indent=2))
        elif args.command == "work":
            work(workspace, args.url, args.timeout, args.once)
        elif args.command == "retry":
            with connect(workspace) as db:
                cursor = db.execute("UPDATE jobs SET state='queued', error='', updated_at=? WHERE id=? AND state IN ('failed', 'uncertain')",
                                    (time.time(), args.id))
                if not cursor.rowcount:
                    raise ValueError("failed/uncertainのジョブだけ再投入できます")
            print(args.id + ": queued（同じseed）")
        elif args.command == "recover":
            with (workspace / ".runtime" / "worker.lock").open("a+") as lock:
                try:
                    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                except BlockingIOError:
                    raise ValueError("ワーカー停止後にrecoverしてください")
                with connect(workspace) as db:
                    cursor = db.execute("UPDATE jobs SET state='uncertain', error='異常終了後に手動回復。Draw Things側の結果を確認してください。', updated_at=? WHERE id=? AND state='running'",
                                        (time.time(), args.id))
                    if not cursor.rowcount:
                        raise ValueError("runningのジョブだけ回復できます")
            print(args.id + ": uncertain（まだ再投入していません）")
        else:
            with connect(workspace) as db:
                for row in db.execute("SELECT id, lane, state, error FROM jobs ORDER BY created_at DESC"):
                    print(json.dumps(dict(row), ensure_ascii=False))
    except (ValueError, OSError, URLError) as error:
        parser.exit(1, "エラー: " + str(error) + "\n")


if __name__ == "__main__":
    main()
