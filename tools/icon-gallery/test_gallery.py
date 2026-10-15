"""Boundary and integration checks using an isolated workspace and fake Draw Things."""
import base64
import concurrent.futures
import fcntl
import json
import tempfile
import threading
import unittest
import struct
import zlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import quote
from urllib.request import Request, urlopen

from common import access_token, atomic_json, connect, gallery, image_path, setup
from jobs import amend, claim, enqueue, finish, generate, initial_image, validate_job, work
from server import make_handler

PNG = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/a9sAAAAASUVORK5CYII=")
JOB = {"title": "試験画像", "prompt": "test shape", "model": "sd_xl_base_1.0_q6p_q8p.ckpt", "seed": 42}


class GalleryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="icon-gallery-test-")
        self.workspace = setup(Path(self.temporary.name))
        self.token = access_token(self.workspace)
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), make_handler(self.workspace, self.token))
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.url = "http://127.0.0.1:" + str(self.server.server_port)

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.temporary.cleanup()

    def request(self, path, body=None, cookie=None, custom=True):
        headers = {"Cookie": cookie} if cookie else {}
        if body is not None:
            headers["Content-Type"] = "application/json"
            if custom:
                headers["X-Icon-Gallery"] = "1"
        return urlopen(Request(self.url + path, data=json.dumps(body).encode() if body is not None else None,
                               headers=headers), timeout=10)

    def login(self):
        with self.request("/api/login", {"token": self.token}) as response:
            return response.headers["Set-Cookie"].split(";", 1)[0]

    def add_image(self, name="A/images/sample.png"):
        path = self.workspace / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(PNG)
        return path

    def test_private_endpoints_require_auth(self):
        self.add_image()
        for route in ("/api/gallery", "/image?id=A%2Fimages%2Fsample.png"):
            with self.assertRaises(HTTPError) as result:
                self.request(route)
            self.assertEqual(result.exception.code, 401)
        with self.assertRaises(HTTPError) as result:
            self.request("/api/login", {"token": "wrong"})
        self.assertEqual(result.exception.code, 401)
        with self.request("/api/gallery", cookie=self.login()) as response:
            self.assertEqual(len(json.load(response)["items"]), 1)

    def test_origin_boundary_and_review_persistence(self):
        self.add_image()
        cookie = self.login()
        review = {"id": "A/images/sample.png", "state": "candidate", "note": "輪郭を確認"}
        with self.assertRaises(HTTPError) as result:
            self.request("/api/review", review, cookie=cookie, custom=False)
        self.assertEqual(result.exception.code, 403)
        with self.request("/api/review", review, cookie=cookie) as response:
            self.assertEqual(json.load(response)["state"], "candidate")
        # Separate connection / recreated workspace retains the shared review.
        setup(self.workspace)
        self.assertEqual(gallery(self.workspace)["items"][0]["review"]["note"], "輪郭を確認")
        with self.request("/api/logout", {}, cookie=cookie) as response:
            self.assertIn("Max-Age=0", response.headers["Set-Cookie"])

    def test_traversal_symlink_and_metadata_boundaries(self):
        self.add_image()
        external = self.workspace / "private.png"
        external.write_bytes(PNG)
        (self.workspace / "B/images/leak.png").symlink_to(external)
        (self.workspace / "C/images/leak-dir").symlink_to(self.workspace / "A/images", target_is_directory=True)
        cookie = self.login()
        for image_id in ("../private.png", "A/images/../../private.png", "B/images/leak.png", "C/images/leak-dir/sample.png"):
            with self.assertRaises(HTTPError) as result:
                self.request("/image?id=" + quote(image_id, safe=""), cookie=cookie)
            self.assertEqual(result.exception.code, 404)
        atomic_json(self.workspace / "A/images/sample.png.json", {"prompt": "<script>bad</script>", "secret": "hidden"})
        items = gallery(self.workspace)["items"]
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0]["metadata"]["prompt"], "<script>bad</script>")
        self.assertNotIn("secret", items[0]["metadata"])

    def test_scan_ignores_partial_and_corrupt_sidecars(self):
        path = self.add_image("C/images/nested/test.png")
        path.with_name("partial.png.tmp").write_bytes(PNG)
        path.with_name("empty.png").write_bytes(b"")
        path.with_name("test.png.json").write_text("broken")
        items = gallery(self.workspace)["items"]
        self.assertEqual([x["id"] for x in items], ["C/images/nested/test.png"])
        self.assertEqual(items[0]["metadata"], {})

    def test_thumbnail_and_original_are_authenticated(self):
        self.add_image()
        cookie = self.login()
        for suffix in ("", "&thumb=1"):
            with self.request("/image?id=A%2Fimages%2Fsample.png" + suffix, cookie=cookie) as response:
                self.assertEqual(response.headers["Content-Type"], "image/png")
                self.assertTrue(response.read().startswith(b"\x89PNG"))

    def test_concurrent_producers_and_atomic_claim(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            ids = list(pool.map(lambda lane: enqueue(self.workspace, lane, JOB), ["A", "B", "C"] * 4))
        self.assertEqual(len(set(ids)), 12)
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            claimed = list(pool.map(lambda _: claim(self.workspace), range(12)))
        self.assertEqual(len({x["id"] for x in claimed}), 12)
        self.assertIsNone(claim(self.workspace))

    def test_validation_and_seed_are_reproducible(self):
        self.assertEqual(validate_job(JOB)["seed"], 42)
        random = validate_job({**JOB, "seed": -1})
        self.assertGreaterEqual(random["seed"], 0)
        for change in ({"prompt": ""}, {"width": 900}, {"width": True}, {"steps": 1000}, {"model": ""}, {"seed": 2**40}, {"unknown": True}, {"clip_skip": 0}, {"clip_skip": 24}, {"clip_skip": True}, {"prompt": "REPLACE_WITH_APPROVED_ICON_BRIEF"}):
            with self.assertRaises(ValueError):
                validate_job({**JOB, **change})

    def test_worker_lock_prevents_duplicate_consumers(self):
        with (self.workspace / ".runtime/worker.lock").open("a+") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with self.assertRaisesRegex(ValueError, "すでに起動"):
                work(self.workspace, "http://127.0.0.1:1", 2, once=True)

    def test_amend_only_queued_job_and_keep_original_seed(self):
        job_id = enqueue(self.workspace, "A", JOB)
        changed = amend(self.workspace, job_id, {**JOB, "prompt": "revised horizontal pose", "seed": -1})
        self.assertEqual(changed["seed"], 42)
        row = claim(self.workspace)
        self.assertEqual(json.loads(row["payload"])["prompt"], "revised horizontal pose")
        with self.assertRaisesRegex(ValueError, "待機中"):
            amend(self.workspace, job_id, JOB)

    def test_img2img_reference_boundaries_and_actual_http_payload(self):
        def chunk(kind, body):
            return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", zlib.crc32(kind + body))
        png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 256, 256, 8, 2, 0, 0, 0))
        png += chunk(b"IDAT", zlib.compress((b"\0" + b"\0" * 768) * 256)) + chunk(b"IEND", b"")
        reference = self.workspace / "study/references/pose.png"
        reference.parent.mkdir(parents=True)
        reference.write_bytes(png)
        job = {**JOB, "mode": "img2img", "init_image": "study/references/pose.png",
               "denoising_strength": 0.55, "width": 256, "height": 256}
        calls = []

        class FakeImageBackend(BaseHTTPRequestHandler):
            def log_message(self, *args):
                pass

            def do_POST(self):
                calls.append((self.path, json.loads(self.rfile.read(int(self.headers["Content-Length"])))))
                body = json.dumps({"images": [base64.b64encode(png).decode()]}).encode()
                self.send_response(200)
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

        backend = ThreadingHTTPServer(("127.0.0.1", 0), FakeImageBackend)
        thread = threading.Thread(target=backend.serve_forever, daemon=True)
        thread.start()
        try:
            enqueue(self.workspace, "A", job)
            outputs = generate(self.workspace, claim(self.workspace), "http://127.0.0.1:" + str(backend.server_port), 5)
            self.assertEqual(calls[0][0], "/sdapi/v1/img2img")
            self.assertEqual(base64.b64decode(calls[0][1]["init_images"][0]), png)
            self.assertEqual(calls[0][1]["denoising_strength"], 0.55)
            self.assertEqual(len(outputs), 1)
            for invalid in ("../references/pose.png", "/study/references/pose.png", "study/../pose.png"):
                with self.assertRaises(ValueError):
                    validate_job({**job, "init_image": invalid})
            (reference.parent / "link.png").symlink_to(reference)
            with self.assertRaisesRegex(ValueError, "シンボリック"):
                initial_image(self.workspace, {**job, "init_image": "study/references/link.png"})
            with self.assertRaisesRegex(ValueError, "サイズ"):
                initial_image(self.workspace, {**job, "width": 512})
        finally:
            backend.shutdown()
            backend.server_close()
            thread.join()

    def test_saved_image_after_crash_is_not_generated_again(self):
        job_id = enqueue(self.workspace, "A", JOB)
        row = claim(self.workspace)
        path = self.add_image("A/images/" + job_id + ".png")
        atomic_json(path.with_name(path.name + ".json"), {**JOB, "job_id": job_id})
        self.assertEqual(generate(self.workspace, row, "http://127.0.0.1:1", 1), ["A/images/" + job_id + ".png"])

    def test_backend_failure_stops_without_consuming_pending_queue(self):
        class FailingBackend(BaseHTTPRequestHandler):
            def log_message(self, *args):
                pass

            def do_GET(self):
                body = json.dumps({"model": JOB["model"]}).encode()
                self.send_response(200)
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            def do_POST(self):
                self.rfile.read(int(self.headers["Content-Length"]))
                self.send_response(500)
                self.send_header("Content-Length", "0")
                self.end_headers()

        backend = ThreadingHTTPServer(("127.0.0.1", 0), FailingBackend)
        thread = threading.Thread(target=backend.serve_forever, daemon=True)
        thread.start()
        try:
            first = enqueue(self.workspace, "A", JOB)
            second = enqueue(self.workspace, "B", JOB)
            with self.assertRaisesRegex(ValueError, "ワーカーを停止"):
                work(self.workspace, "http://127.0.0.1:" + str(backend.server_port), 2)
            with connect(self.workspace) as db:
                states = {row["id"]: row["state"] for row in db.execute("SELECT id,state FROM jobs")}
            self.assertEqual(states, {first: "uncertain", second: "queued"})
        finally:
            backend.shutdown()
            backend.server_close()
            thread.join()

    def test_three_lanes_generate_through_fake_draw_things(self):
        calls = []

        class FakeDrawThings(BaseHTTPRequestHandler):
            def log_message(self, *args):
                pass

            def do_GET(self):
                self.send({"model": JOB["model"]})

            def do_POST(self):
                payload = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
                calls.append((self.path, payload))
                self.send({"images": [base64.b64encode(PNG).decode()]})

            def send(self, data):
                body = json.dumps(data).encode()
                self.send_response(200)
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

        backend = ThreadingHTTPServer(("127.0.0.1", 0), FakeDrawThings)
        thread = threading.Thread(target=backend.serve_forever, daemon=True)
        thread.start()
        try:
            ids = [enqueue(self.workspace, lane, {**JOB, "title": lane, **({"clip_skip": 1} if lane == "A" else {})}) for lane in ("A", "B", "C")]
            for _ in ids:
                work(self.workspace, "http://127.0.0.1:" + str(backend.server_port), 5, once=True)
            items = gallery(self.workspace)["items"]
            self.assertEqual({x["lane"] for x in items}, {"A", "B", "C"})
            self.assertEqual({x["metadata"]["seed"] for x in items}, {42})
            self.assertEqual([x[0] for x in calls], ["/sdapi/v1/txt2img"] * 3)
            self.assertTrue(all(x[1]["batch_size"] == 1 for x in calls))
            self.assertTrue(all(x[1]["zero_negative_prompt"] is False for x in calls))
            self.assertEqual(calls[0][1]["clip_skip"], 1)
            self.assertNotIn("clip_skip", calls[1][1])
            sidecar = self.workspace / "A/images" / (ids[0] + ".png.json")
            self.assertEqual(json.loads(sidecar.read_text())["clip_skip"], 1)
            with connect(self.workspace) as db:
                self.assertEqual({x[0] for x in db.execute("SELECT state FROM jobs")}, {"done"})
        finally:
            backend.shutdown()
            backend.server_close()
            thread.join()


if __name__ == "__main__":
    unittest.main()
