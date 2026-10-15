#!/usr/bin/env python3
"""Authenticated mobile review gallery, serving only this workspace's images."""
import argparse
import hashlib
import hmac
import json
import os
import shutil
import subprocess
import threading
import time
from http.cookies import SimpleCookie
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlsplit

from common import (DEFAULT_WORKSPACE, IMAGE_TYPES, REVIEW_STATES, access_token,
                    connect, gallery, image_path, setup)

WEB = Path(__file__).parent / "web"
THUMB_LOCK = threading.Lock()


def thumbnail(workspace, path):
    if not Path("/usr/bin/sips").exists():
        return path
    stat = path.stat()
    key = hashlib.sha256((str(path) + str(stat.st_mtime_ns) + str(stat.st_size)).encode()).hexdigest()
    folder = workspace / ".runtime" / "thumbnails"
    folder.mkdir(exist_ok=True)
    dest = folder / (key + ".png")
    with THUMB_LOCK:
        if not dest.exists():
            temporary = dest.with_suffix(".tmp.png")
            try:
                subprocess.run(["/usr/bin/sips", "-Z", "360", "-s", "format", "png",
                                str(path), "--out", str(temporary)],
                               check=True, timeout=30, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                temporary.replace(dest)
            except (OSError, subprocess.SubprocessError):
                if temporary.exists():
                    temporary.unlink()
                return path
    return dest


def make_handler(workspace, token):
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, format, *args):
            # Paths and authentication material are intentionally omitted.
            pass

        def headers_for(self, status, mime, length, extra=None):
            self.send_response(status)
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(length))
            self.send_header("Cache-Control", "private, no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Referrer-Policy", "no-referrer")
            self.send_header("X-Frame-Options", "DENY")
            self.send_header("Content-Security-Policy", "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'")
            for key, value in (extra or {}).items():
                self.send_header(key, value)
            self.end_headers()

        def respond(self, data, status=200, extra=None):
            body = json.dumps(data, ensure_ascii=False).encode()
            self.headers_for(status, "application/json; charset=utf-8", len(body), extra)
            self.wfile.write(body)

        def authorized(self):
            cookie = SimpleCookie()
            try:
                cookie.load(self.headers.get("Cookie", ""))
                value = cookie["icon_gallery"].value if "icon_gallery" in cookie else ""
                return hmac.compare_digest(value, token)
            except Exception:
                return False

        def file(self, path, mime):
            with path.open("rb") as stream:
                self.headers_for(200, mime, path.stat().st_size)
                shutil.copyfileobj(stream, self.wfile)

        def do_GET(self):
            parsed = urlsplit(self.path)
            static = {"/": ("index.html", "text/html; charset=utf-8"),
                      "/app.js": ("app.js", "text/javascript; charset=utf-8"),
                      "/style.css": ("style.css", "text/css; charset=utf-8")}
            try:
                if parsed.path in static:
                    name, mime = static[parsed.path]
                    return self.file(WEB / name, mime)
                if parsed.path == "/api/health":
                    return self.respond({"ok": True, "pid": os.getpid()})
                if not self.authorized():
                    return self.respond({"error": "アクセスキーで開いてください"}, 401)
                if parsed.path == "/api/gallery":
                    return self.respond(gallery(workspace))
                if parsed.path == "/image":
                    query = parse_qs(parsed.query)
                    path = image_path(workspace, query.get("id", [""])[0])
                    if query.get("thumb") == ["1"]:
                        path = thumbnail(workspace, path)
                    return self.file(path, IMAGE_TYPES[path.suffix.lower()])
                return self.respond({"error": "見つかりません"}, 404)
            except (ValueError, FileNotFoundError):
                self.respond({"error": "見つかりません"}, 404)
            except (BrokenPipeError, ConnectionResetError):
                pass

        def do_POST(self):
            if self.headers.get("X-Icon-Gallery") != "1" or self.headers.get("Content-Type", "").split(";")[0] != "application/json":
                return self.respond({"error": "JSON APIを使用してください"}, 403)
            try:
                length = int(self.headers.get("Content-Length", "0"))
                if not 0 < length <= 16384:
                    return self.respond({"error": "リクエストサイズが不正です"}, 400)
                data = json.loads(self.rfile.read(length))
                if not isinstance(data, dict):
                    raise ValueError("オブジェクトを指定してください")
                path = urlsplit(self.path).path
                if path == "/api/login":
                    if not isinstance(data.get("token"), str) or not hmac.compare_digest(data["token"], token):
                        return self.respond({"error": "アクセスキーが違います"}, 401)
                    secure = "; Secure" if self.headers.get("X-Forwarded-Proto") == "https" else ""
                    return self.respond({"ok": True}, extra={"Set-Cookie":
                        "icon_gallery=" + token + "; Path=/; HttpOnly; SameSite=Strict; Max-Age=2592000" + secure})
                if not self.authorized():
                    return self.respond({"error": "ログインしてください"}, 401)
                if path == "/api/logout":
                    return self.respond({"ok": True}, extra={"Set-Cookie": "icon_gallery=; Path=/; Max-Age=0; HttpOnly; SameSite=Strict"})
                if path != "/api/review":
                    return self.respond({"error": "見つかりません"}, 404)
                image_id = data.get("id")
                state, note = data.get("state"), data.get("note", "")
                if not isinstance(image_id, str) or state not in REVIEW_STATES or not isinstance(note, str) or len(note) > 4000:
                    raise ValueError("レビュー内容が不正です")
                image_path(workspace, image_id)
                updated = time.time()
                with connect(workspace) as db:
                    db.execute("INSERT INTO reviews VALUES (?, ?, ?, ?) ON CONFLICT(image_id) DO UPDATE SET state=excluded.state, note=excluded.note, updated_at=excluded.updated_at",
                               (image_id, state, note, updated))
                self.respond({"state": state, "note": note, "updated_at": updated})
            except (ValueError, TypeError):
                self.respond({"error": "内容を確認してください"}, 400)
            except (BrokenPipeError, ConnectionResetError):
                pass

    return Handler


def main():
    parser = argparse.ArgumentParser(description="アイコン確認ギャラリー")
    parser.add_argument("--workspace", type=Path, default=DEFAULT_WORKSPACE)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    workspace = setup(args.workspace)
    token = access_token(workspace)
    server = ThreadingHTTPServer((args.host, args.port), make_handler(workspace, token))
    print("アイコンギャラリー: http://127.0.0.1:%d/#token=%s" % (server.server_port, token), flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
