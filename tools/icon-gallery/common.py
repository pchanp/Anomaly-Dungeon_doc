"""Shared workspace, durable queue and review storage (Python standard library)."""
import json
import os
import secrets
import sqlite3
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
DEFAULT_WORKSPACE = REPO / "work" / "icon-generation"
LANES = ("A", "B", "C")
IMAGE_TYPES = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp"}
REVIEW_STATES = ("unreviewed", "candidate", "revise", "rejected")


def setup(workspace):
    workspace = Path(workspace).resolve()
    for lane in LANES:
        (workspace / lane / "images").mkdir(parents=True, exist_ok=True)
        (workspace / lane / "requests").mkdir(parents=True, exist_ok=True)
    runtime = workspace / ".runtime"
    runtime.mkdir(parents=True, exist_ok=True)
    with connect(workspace) as db:
        db.executescript("""
            CREATE TABLE IF NOT EXISTS reviews (
                image_id TEXT PRIMARY KEY, state TEXT NOT NULL, note TEXT NOT NULL,
                updated_at REAL NOT NULL
            );
            CREATE TABLE IF NOT EXISTS jobs (
                id TEXT PRIMARY KEY, lane TEXT NOT NULL, payload TEXT NOT NULL,
                state TEXT NOT NULL, created_at REAL NOT NULL, updated_at REAL NOT NULL,
                error TEXT NOT NULL DEFAULT '', outputs TEXT NOT NULL DEFAULT '[]'
            );
        """)
    return workspace


def connect(workspace):
    db = sqlite3.connect(str(Path(workspace) / ".runtime" / "gallery.sqlite3"), timeout=30)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA busy_timeout = 30000")
    return db


def atomic_json(path, data):
    path = Path(path)
    temporary = path.with_name(path.name + "." + secrets.token_hex(5) + ".tmp")
    try:
        temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        os.replace(str(temporary), str(path))
    finally:
        if temporary.exists():
            temporary.unlink()


def read_json(path, default=None):
    try:
        if Path(path).stat().st_size > 1024 * 1024:
            return default
        return json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return default


def image_path(workspace, image_id):
    """Only lane images are addressable; reject traversal and all symlink paths."""
    parts = image_id.split("/")
    if len(parts) < 3 or parts[0] not in LANES or parts[1] != "images":
        raise ValueError("画像パスが不正です")
    if any(part in ("", ".", "..") or "\\" in part for part in parts):
        raise ValueError("画像パスが不正です")
    path = Path(workspace)
    for part in parts:
        path = path / part
        if path.is_symlink():
            raise ValueError("シンボリックリンクは対象外です")
    if path.suffix.lower() not in IMAGE_TYPES or not path.is_file():
        raise ValueError("画像が見つかりません")
    return path


def gallery(workspace):
    with connect(workspace) as db:
        reviews = {row["image_id"]: dict(row) for row in db.execute("SELECT * FROM reviews")}
        jobs = [dict(row) for row in db.execute(
            "SELECT id, lane, state, created_at, updated_at, error, outputs FROM jobs ORDER BY created_at DESC LIMIT 100"
        )]
    items = []
    for lane in LANES:
        for path in (workspace / lane / "images").rglob("*"):
            if path.suffix.lower() not in IMAGE_TYPES:
                continue
            image_id = path.relative_to(workspace).as_posix()
            try:
                path = image_path(workspace, image_id)
                stat = path.stat()
                if stat.st_size == 0:
                    continue
                sidecar = path.with_name(path.name + ".json")
                metadata = read_json(sidecar, {}) if not sidecar.is_symlink() else {}
                if not isinstance(metadata, dict):
                    metadata = {}
                # Metadata is text, never markup or executable URLs.
                metadata = {key: metadata[key] for key in (
                    "title", "target_id", "prompt", "negative_prompt", "seed", "model",
                    "source_docs", "notes", "job_id", "width", "height", "steps", "cfg_scale", "sampler_name"
                ) if key in metadata}
                items.append({"id": image_id, "lane": lane, "filename": path.name,
                              "modified": stat.st_mtime, "bytes": stat.st_size,
                              "metadata": metadata, "review": reviews.get(image_id, {
                                  "state": "unreviewed", "note": "", "updated_at": 0})})
            except (OSError, ValueError):
                continue
    items.sort(key=lambda item: (item["modified"], item["id"]), reverse=True)
    return {"items": items, "jobs": jobs, "updated_at": time.time()}


def access_token(workspace):
    path = workspace / ".runtime" / "access-token"
    try:
        token = path.read_text().strip()
        if len(token) >= 32:
            return token
    except FileNotFoundError:
        pass
    token = secrets.token_urlsafe(32)
    try:
        fd = os.open(str(path), os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    except FileExistsError:
        return path.read_text().strip()
    with os.fdopen(fd, "w") as stream:
        stream.write(token + "\n")
    return token
