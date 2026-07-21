"""古诗栏目：为每首诗页自动注入"上一首 / 下一首"导航。

仅对 classical-poems 目录下的诗页（非 index）生效。
按文件名在同一年级目录内排序，确定前后顺序。
"""
from __future__ import annotations

import re
from pathlib import PurePosixPath


def _is_poem_page(page) -> bool:
    src = getattr(page, "file", None)
    if not src:
        return False
    src_path = (getattr(src, "src_path", "") or "").replace("\\", "/")
    if "classical-poems/" not in src_path:
        return False
    # skip index pages and the hub index
    if src_path.endswith("index.md"):
        return False
    if src_path in ("classical-poems/index.md",):
        return False
    return True


def on_page_markdown(markdown: str, *, page=None, config=None, files=None) -> str | None:
    if not _is_poem_page(page):
        return None

    if files is None:
        return None

    src = page.file
    src_path = src.src_path.replace("\\", "/")
    current_dir = str(PurePosixPath(src_path).parent)

    # collect sibling poem pages in the same grade directory
    siblings: list = []
    for f in files:
        p = (getattr(f, "src_path", "") or "").replace("\\", "/")
        if p == src_path:
            continue
        if str(PurePosixPath(p).parent) != current_dir:
            continue
        if p.endswith("index.md"):
            continue
        siblings.append(f)

    # sort by src_path (posix) for stable ordering
    def sort_key(f) -> str:
        return (getattr(f, "src_path", "") or "").replace("\\", "/")

    siblings.sort(key=sort_key)

    # split into < and > current
    smaller = [f for f in siblings if sort_key(f) < src_path]
    greater = [f for f in siblings if sort_key(f) > src_path]
    prev_file = smaller[-1] if smaller else None
    next_file = greater[0] if greater else None

    def link_for(f) -> str:
        if f is None:
            return ""
        # page title
        title = ""
        page_obj = getattr(f, "page", None)
        if page_obj:
            title = getattr(page_obj, "title", "") or ""
        if not title:
            # fallback: derive from filename
            name = PurePosixPath((getattr(f, "src_path", "") or "").replace("\\", "/")).stem
            title = name
        # url relative to current page
        f_url = (getattr(f, "url", "") or "").replace("\\", "/")
        cur_url = (getattr(src, "url", "") or "").replace("\\", "/")
        cur_dir = str(PurePosixPath(cur_url).parent)
        rel = _relative_link(cur_dir, f_url)
        return f'<a class="poem-pager__link" href="{rel}">{title}</a>'

    def _relative_link(from_dir: str, to_url: str) -> str:
        from_parts = [p for p in from_dir.split("/") if p]
        to_parts = [p for p in to_url.split("/") if p]
        i = 0
        while i < len(from_parts) and i < len(to_parts) - 1 and from_parts[i] == to_parts[i]:
            i += 1
        up = [".."] * (len(from_parts) - i)
        down = to_parts[i:]
        rel = "/".join(up + down)
        return rel or "./"

    prev_html = link_for(prev_file)
    next_html = link_for(next_file)

    if not prev_html and not next_html:
        return None

    pager = ['<nav class="poem-pager">']
    if prev_html:
        pager.append(f'<span class="poem-pager__item poem-pager__prev"><span class="poem-pager__label">上一首</span>{prev_html}</span>')
    else:
        pager.append('<span class="poem-pager__item poem-pager__prev poem-pager__item--empty"></span>')
    pager.append('<a class="poem-pager__item poem-pager__home" href="../">本年级目录</a>')
    if next_html:
        pager.append(f'<span class="poem-pager__item poem-pager__next"><span class="poem-pager__label">下一首</span>{next_html}</span>')
    else:
        pager.append('<span class="poem-pager__item poem-pager__next poem-pager__item--empty">已是本年级最后一首</span>')
    pager.append('</nav>')

    return markdown + "\n\n" + "\n".join(pager) + "\n"