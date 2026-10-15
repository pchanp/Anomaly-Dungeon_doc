#!/usr/bin/env python3
"""Keep the private gallery and a Cloudflare development tunnel together."""
import argparse
import json
import os
import queue
import re
import shutil
import signal
import subprocess
import sys
import threading
import time
from pathlib import Path
from urllib.request import urlopen

from common import DEFAULT_WORKSPACE, access_token, atomic_json, setup


def stop(process):
    if process and process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def main():
    parser = argparse.ArgumentParser(description="外出先からアイコンギャラリーを開く")
    parser.add_argument("--workspace", type=Path, default=DEFAULT_WORKSPACE)
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--cloudflared", type=Path)
    args = parser.parse_args()
    workspace = setup(args.workspace)
    binary = args.cloudflared or shutil.which("cloudflared") or workspace / ".runtime" / "bin" / "cloudflared"
    if not Path(binary).is_file():
        parser.exit(1, "cloudflaredが必要です。READMEの外出先接続手順を参照してください。\n")
    token = access_token(workspace)
    runtime = workspace / ".runtime"
    server = tunnel = None
    share_file = runtime / "share.json"

    def interrupt(signum, frame):
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, interrupt)
    try:
        server_log = (runtime / "server.log").open("w")
        server = subprocess.Popen([sys.executable, str(Path(__file__).parent / "server.py"),
                                   "--workspace", str(workspace), "--port", str(args.port)],
                                  stdout=server_log, stderr=subprocess.STDOUT)
        address = "http://127.0.0.1:" + str(args.port)
        for attempt in range(50):
            if server.poll() is not None:
                parser.exit(1, "ギャラリーが起動しませんでした。既存プロセス・server.logを確認してください。\n")
            try:
                with urlopen(address + "/api/health", timeout=1) as response:
                    if response.status == 200 and json.load(response).get("pid") == server.pid:
                        break
            except OSError:
                time.sleep(.1)
        else:
            raise RuntimeError("ギャラリー起動を確認できませんでした")
        # Quick tunnel only sees the gallery; never forward Draw Things or the repo.
        tunnel = subprocess.Popen([str(binary), "tunnel", "--url", address,
                                   "--protocol", "http2", "--no-autoupdate"],
                                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
        messages = queue.Queue()

        def read_output():
            with (runtime / "tunnel.log").open("w") as log:
                for line in tunnel.stdout:
                    log.write(line)
                    log.flush()
                    messages.put(line)

        threading.Thread(target=read_output, daemon=True).start()
        deadline = time.monotonic() + 60
        remote = None
        while time.monotonic() < deadline:
            if tunnel.poll() is not None:
                raise RuntimeError("外出先接続が起動しませんでした。tunnel.logを確認してください")
            try:
                line = messages.get(timeout=1)
            except queue.Empty:
                continue
            match = re.search(r"https://[a-z0-9-]+\.trycloudflare\.com", line)
            if match:
                remote = match.group(0)
                break
        if not remote:
            raise RuntimeError("外出先URLが発行されませんでした。tunnel.logを確認してください")
        private_link = remote + "/#token=" + token
        atomic_json(share_file, {"url": remote, "private_link": private_link, "started_at": time.time(),
                                 "pid": os.getpid(), "status": "running"})
        share_file.chmod(0o600)
        print("携帯で開くリンク: " + private_link, flush=True)
        print("Macを起動したまま使います。終了: Ctrl+C。再起動するとURLが変わります。", flush=True)
        while server.poll() is None and tunnel.poll() is None:
            time.sleep(1)
        raise RuntimeError("ギャラリーまたは外出先接続が停止しました")
    except KeyboardInterrupt:
        print("ギャラリーと外出先接続を停止します。", flush=True)
    except (OSError, RuntimeError) as error:
        print("エラー: " + str(error), file=sys.stderr)
        sys.exit(1)
    finally:
        stop(tunnel)
        stop(server)
        if share_file.exists():
            share_file.unlink()


if __name__ == "__main__":
    main()
