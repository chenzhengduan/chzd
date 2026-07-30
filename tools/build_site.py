from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DOCS = ROOT / "docs"
CACHE_DIR = ROOT / ".cache"
BUILD_DOCS = CACHE_DIR / "mkdocs-docs"
LOCAL_CONFIG = CACHE_DIR / "mkdocs.local.yml"

CONTENT_TREES = (
    "sales-customer-conversion",
    "short-video-shooting",
    "social-platform-operations",
    "cross-border-ecommerce",
    "alibaba-ecommerce",
    "profile",
    "ai-agent-book",
)


def prepare_docs_tree() -> None:
    """Materialize the docs tree without relying on Git symlink support."""
    if BUILD_DOCS.exists():
        shutil.rmtree(BUILD_DOCS)
    BUILD_DOCS.mkdir(parents=True)

    shutil.copy2(SOURCE_DOCS / "index.md", BUILD_DOCS / "index.md")
    shutil.copy2(SOURCE_DOCS / ".pages", BUILD_DOCS / ".pages")
    shutil.copytree(SOURCE_DOCS / "assets", BUILD_DOCS / "assets")

    for tree_name in CONTENT_TREES:
        source = ROOT / tree_name
        if not source.is_dir():
            raise FileNotFoundError(f"Missing content tree: {source}")
        shutil.copytree(source, BUILD_DOCS / tree_name)


def write_local_config() -> None:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    config = "\n".join(
        [
            f'INHERIT: "{(ROOT / "mkdocs.yml").as_posix()}"',
            f'docs_dir: "{BUILD_DOCS.as_posix()}"',
            f'site_dir: "{(ROOT / ".site").as_posix()}"',
            "hooks:",
            f'  - "{(ROOT / "hooks" / "standalone_title.py").as_posix()}"',
            "",
        ]
    )
    LOCAL_CONFIG.write_text(config, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="跨平台构建完整 MkDocs 知识库")
    parser.add_argument("--strict", action="store_true", help="将 MkDocs 警告视为错误")
    args = parser.parse_args()

    prepare_docs_tree()
    write_local_config()

    command = [
        sys.executable,
        "-m",
        "mkdocs",
        "build",
        "--config-file",
        str(LOCAL_CONFIG),
    ]
    if args.strict:
        command.append("--strict")
    return subprocess.call(command, cwd=ROOT)


if __name__ == "__main__":
    raise SystemExit(main())
