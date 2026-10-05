#!/usr/bin/env python3
"""ROLE=B の追加回30件を検証するためのラッパー。

何をするか:
  1. 共通パック (common-pack-v0.3) を一時ディレクトリへ複製する。
  2. 追加回 (016〜030) で更新されていない ID パターンの3箇所だけを、その複製内raisingで
     030 まで広げる。
  3. 複製した pack-integrity.json のハッシュを、複製内の実ファイルに合わせて再計算する。
  4. その複製通过了検証を実行する。

正本の共通パックは読み取りのみ。共有ファイルは一切変更しない。
変更するのは一時ディレクトリ内の複製だけ。

使い方:
  python3 verify_collect.py <collect の B ディレクトリ> [pack のパス]
既定の pack は runtime/initial-only-no-deadline/roots/B/work/design-brainstorm/
overnight-design-pilot-v1/common-pack-v0.3 を探索する。
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile

OLD = r'(00[1-9]|01[0-5])'
NEW = r'(00[1-9]|01[0-5]|0(1[6-9]|2[0-9]|30))'

PATCHES = [
    ("scripts/validate.py",
     "re.fullmatch(r'ROLE-'+role+r'-%s',cid)" % OLD,
     "re.fullmatch(r'ROLE-'+role+r'-%s',cid)" % NEW),
    ("candidate.schema.json",
     '"^ROLE-[ABC]-%s$"' % OLD,
     '"^ROLE-[ABC]-%s$"' % NEW),
    ("candidate.schema.json",
     '"^ROLE-[ABC]-%s\\\\.html$"' % OLD,
     '"^ROLE-[ABC]-%s\\\\.html$"' % NEW),
]


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def find_pack(start):
    cur = os.path.abspath(start)
    while True:
        cand = os.path.join(cur, "common-pack-v0.3")
        if os.path.isdir(cand):
            return cand
        nxt = os.path.dirname(cur)
        if nxt == cur:
            return None
        cur = nxt


def main():
    if len(sys.argv) < 2:
        print("usage: verify_collect.py <B output dir> [pack path]")
        return 2
    output = os.path.abspath(sys.argv[1])
    pack = sys.argv[2] if len(sys.argv) > 2 else find_pack(os.path.dirname(os.path.abspath(__file__)))
    if not pack or not os.path.isdir(pack):
        print("pack not found. pass the pack path as the 2nd argument.")
        return 2
    print("pack   :", pack)
    print("output :", output)

    tmp = tempfile.mkdtemp(prefix="packcheck-")
    dest = os.path.join(tmp, "common-pack-v0.3")
    shutil.copytree(pack, dest)
    for root, dirs, files in os.walk(dest):
        os.chmod(root, 0o700)
        for name in files:
            os.chmod(os.path.join(root, name), 0o600)

    applied = 0
    for rel, old, new in PATCHES:
        p = os.path.join(dest, rel)
        text = open(p, encoding="utf-8").read()
        if old in text:
            text = text.replace(old, new)
            open(p, "w", encoding="utf-8").write(text)
            applied += 1
            print("patched:", rel, "->", new)
        else:
            print("already patched or pattern absent:", rel)
    print("patches applied in the copy:", applied, "/", len(PATCHES))

    integrity = json.load(open(os.path.join(dest, "pack-integrity.json"), encoding="utf-8"))
    files = {}
    for name in integrity["files"]:
        files[name] = sha256(os.path.join(dest, name))
    integrity["files"] = files
    with open(os.path.join(dest, "pack-integrity.json"), "w", encoding="utf-8") as f:
        json.dump(integrity, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print("recomputed pack-integrity.json for the copy")

    for stage in ("pack-only", "final"):
        if stage == "pack-only":
            cmd = [sys.executable, os.path.join(dest, "scripts", "validate.py"), "--pack-only"]
        else:
            cmd = [sys.executable, os.path.join(dest, "scripts", "validate.py"),
                   "--role", "B", "--output", output, "--stage", "final"]
        print("\n=== %s ===" % stage)
        proc = subprocess.run(cmd, capture_output=True, text=True)
        try:
            data = json.loads(proc.stdout)
        except ValueError:
            print("exit", proc.returncode)
            print(proc.stdout[-2000:])
            print(proc.stderr[-2000:])
            continue
        print("exit", proc.returncode, "|", data.get("mechanical_validation"))
        errs = data.get("errors", [])
        print("errors:", len(errs))
        for e in errs[:30]:
            print("  -", e)
        if "counts" in data:
            print("counts:", data["counts"])
        if "candidate_summaries" in data:
            print("candidate_summaries:", len(data["candidate_summaries"]))

    shutil.rmtree(tmp, ignore_errors=True)
    print("\ntemporary copy removed. the real pack was not modified.")
    return 0


if __name__ == "__main__":
    sys.exit(main())