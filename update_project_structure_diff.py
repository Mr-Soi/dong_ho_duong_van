#!/usr/bin/env python3
"""
update_project_structure_diff.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
• Quét cấu trúc dự án, sinh cây Markdown + JSON.
• So sánh với snapshot cũ → tạo diff Markdown.
• Tự động sinh JSON Schema cho *.json* / *.jsonl* (mới hoặc chỉnh sửa).
"""

from __future__ import annotations
import hashlib
import json
import os
import sys
from datetime import datetime
from typing import Dict, Set, Tuple

# ======= CẤU HÌNH ======= #
PROJECT_ROOT  = r"F:\dhdv_stack_v_2.9"

SNAPSHOT_JSON = os.path.join(PROJECT_ROOT, ".project_snapshot.json")
OUTPUT_JSON   = os.path.join(PROJECT_ROOT, "project_structure.json")
OUTPUT_MD     = os.path.join(PROJECT_ROOT, "project_structure.md")
OUTPUT_DIFF   = os.path.join(PROJECT_ROOT, "project_structure_diff.md")

SCHEMAS_DIR   = os.path.join(PROJECT_ROOT, "schemas")    # nơi lưu *.schema.json
MAX_SAMPLE_LINES = 500                                   # lấy mẫu tối đa … dòng khi sinh schema

EXCLUDE_DIRS  = { "node_modules", ".git", "venv", ".venv",
                  "__pycache__", ".pytest_cache", ".mypy_cache",
                  "schemas" }        # tránh vòng lặp khi scan
HASH_EXT      = { ".py", ".ipynb", ".md", ".json", ".yaml", ".yml", ".txt" }
LOG_STEP      = 1_000               # in log mỗi … file
MAX_HASH_SIZE = 20 * 1024**2        # (byte) >20 MB → không băm
# ========================= #


# --------- TIỆN ÍCH --------- #
def file_sha1(path: str, blk: int = 2**16) -> str:
    sha1 = hashlib.sha1()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(blk), b""):
            sha1.update(chunk)
    return sha1.hexdigest()


def build_snapshot(root: str, verbose: bool = True) -> Dict[str, str | None]:
    """
    Trả về dict {rel_path: sha1 | None}.
    • Bỏ qua EXCLUDE_DIRS.
    • Với file > MAX_HASH_SIZE hoặc đuôi không thuộc HASH_EXT → sha = None.
    """
    snap, cnt = {}, 0
    for cur_root, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

        for fname in files:
            if fname == os.path.basename(__file__):
                continue
            cnt += 1
            fpath = os.path.join(cur_root, fname)
            rel   = os.path.relpath(fpath, root).replace("\\", "/")
            size  = os.path.getsize(fpath)
            ext   = os.path.splitext(fname)[1].lower()

            if size > MAX_HASH_SIZE or ext not in HASH_EXT:
                snap[rel] = None
            else:
                snap[rel] = file_sha1(fpath)

            if verbose and cnt % LOG_STEP == 0:
                print(f"…đã xử lý {cnt:,} file")
    if verbose:
        print(f"➡️  Hoàn tất, đã quét {cnt:,} file (đã exclude)")
    return snap


def snapshot_to_tree(snapshot: Dict[str, str | None]) -> Dict:
    tree: Dict = {}
    for path in snapshot:
        parts, node = path.split("/"), tree
        for part in parts[:-1]:
            node = node.setdefault(part, {})
        node[parts[-1]] = None
    return tree


def tree_to_md(tree: Dict, indent: int = 0) -> list[str]:
    lines: list[str] = []
    for key in sorted(tree):
        lines.append("  " * indent + f"- {key}")
        if isinstance(tree[key], dict):
            lines.extend(tree_to_md(tree[key], indent + 1))
    return lines


def save_json(obj: Dict, path: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)


def save_text(lines: list[str], path: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


def load_snapshot() -> Dict | None:
    if os.path.exists(SNAPSHOT_JSON):
        with open(SNAPSHOT_JSON, "r", encoding="utf-8") as f:
            return json.load(f)
    return None


def diff_snap(prev: Dict, curr: Dict) -> Tuple[Set[str], Set[str], Set[str]]:
    prev_files, curr_files = set(prev), set(curr)
    added    = curr_files - prev_files
    removed  = prev_files - curr_files
    modified = {
        p for p in (curr_files & prev_files)
        if prev.get(p) != curr.get(p)
    }
    return added, removed, modified


def write_diff_md(added: Set[str], removed: Set[str], modified: Set[str]):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines = [f"# 📂 Project structure diff — {ts}", ""]

    def sec(title: str, items: Set[str]):
        if items:
            lines.extend([f"## {title} ({len(items)})",
                          *[f"- {p}" for p in sorted(items)],
                          ""])

    sec("➕ Thêm mới", added)
    sec("➖ Đã xoá", removed)
    sec("✏️ Thay đổi nội dung", modified)
    save_text(lines, OUTPUT_DIFF)


# ---------- JSON SCHEMA ---------- #
try:
    from genson import SchemaBuilder
except ImportError:
    print("⚠️  Thiếu thư viện 'genson'. Cài bằng:  pip install genson", file=sys.stderr)
    SchemaBuilder = None   # type: ignore


def build_json_schema(path: str, max_lines: int = MAX_SAMPLE_LINES) -> Dict:
    """
    Đọc tối đa max_lines (hoặc toàn bộ với *.json*) để sinh schema.
    """
    builder = SchemaBuilder()
    ext = os.path.splitext(path)[1].lower()

    if ext == ".jsonl":
        with open(path, "r", encoding="utf-8") as f:
            for i, line in enumerate(f):
                if i >= max_lines:
                    break
                line = line.strip()
                if line:
                    builder.add_object(json.loads(line))
    else:  # .json
        with open(path, "r", encoding="utf-8") as f:
            try:
                obj = json.load(f)
            except json.JSONDecodeError:
                print(f"⚠️  Không parse được JSON: {path}", file=sys.stderr)
                return {}
            builder.add_object(obj)
    return builder.to_schema()


def dump_schema(rel_path: str):
    """
    Lưu schema vào SCHEMAS_DIR, giữ nguyên cấu trúc thư mục.
    """
    if SchemaBuilder is None:
        return  # genson chưa cài
    in_path  = os.path.join(PROJECT_ROOT, rel_path)
    out_path = os.path.join(SCHEMAS_DIR, f"{rel_path}.schema.json")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    schema = build_json_schema(in_path)
    if schema:
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(schema, f, ensure_ascii=False, indent=2)
        print(f"📄  Đã ghi schema: {out_path}")
# ---------------------------------- #


def candidate_for_schema(rel_path: str) -> bool:
    ext = os.path.splitext(rel_path)[1].lower()
    return ext in {".json", ".jsonl"}


def main():
    # 1. Quét hiện trạng
    curr_snap = build_snapshot(PROJECT_ROOT)

    # 2. Ghi cấu trúc (.json + .md)
    tree = snapshot_to_tree(curr_snap)
    save_json(tree, OUTPUT_JSON)
    save_text(tree_to_md(tree), OUTPUT_MD)

    # 3. So sánh với snapshot cũ (nếu có)
    prev_snap = load_snapshot()
    if prev_snap:
        added, removed, modified = diff_snap(prev_snap, curr_snap)
        write_diff_md(added, removed, modified)
        print(f"➕ Added   : {len(added)}")
        print(f"➖ Removed : {len(removed)}")
        print(f"✏️ Modified: {len(modified)}")
        changed_for_schema = added | modified
    else:
        print("ℹ️ Lần quét đầu – tạo snapshot, bỏ qua diff.")
        changed_for_schema = set(curr_snap)  # sinh schema cho tất cả lần đầu

    # 4. Sinh JSON Schema cho file JSON/JSONL mới hoặc thay đổi
    json_targets = [p for p in changed_for_schema if candidate_for_schema(p)]
    if json_targets:
        for p in json_targets:
            dump_schema(p)
    else:
        print("ℹ️  Không có file JSON/JSONL mới hoặc thay đổi → bỏ qua sinh schema.")

    # 5. Lưu snapshot cho lần sau
    save_json(curr_snap, SNAPSHOT_JSON)
    print("✅  Hoàn tất cập nhật project structure & diff (nếu có).")


if __name__ == "__main__":
    main()
