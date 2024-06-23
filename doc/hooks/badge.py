import argparse
from typing import Callable

from mkdocs.config.defaults import MkDocsConfig

def _badge_html(left_text: str, right_text: str = "", typ: str = ""):
    classes = f"mdx-badge mdx-badge--{typ}" if typ else "mdx-badge"
    left_classes = f"mdx-badge__icon" if left_text[0] == ":" and left_text[-1] == ":" else "mdx-badge__text"
    right_classes = f"mdx-badge__icon" if right_text[0] == ":" and right_text[-1] == ":" else "mdx-badge__text"
    return "".join([
        f'<span class="{classes}">',
        f'<span class="{left_classes}">{left_text}</span>' if left_text else "",
        f'<span class="{right_classes}">{right_text}</span>' if right_text else "",
        f"</span>",
    ])


def badge(args: argparse.Namespace, config: MkDocsConfig) -> str:
    if args.command == "badge-version":
        return _badge_html(":material-tag-outline:", args.right_text)
    if args.command == "badge-experimental":
        return _badge_html(":material-flask-outline:", args.right_text)
    return _badge_html(args.left_text, args.right_text)

def HOOKS(sub_parser) -> list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]]:
    parser = sub_parser.add_parser("badge", help="badge")
    parser.add_argument("left_text", type=str, default="", help="left text of the badge")
    parser.add_argument("right_text", type=str, default="", help="right text of the badge")

    parser = sub_parser.add_parser("badge-version", help="experimental badge")
    parser.add_argument("right_text", type=str, default="", help="right text of the badge")

    parser = sub_parser.add_parser("experimental", help="experimental badge")
    parser.add_argument("right_text", type=str, default="", help="right text of the badge")

    parser = sub_parser.add_parser("download", help="download badge")
    parser.add_argument("right_text", type=str, default="", help="right text of the badge")

    return [("badge", badge), ("badge-version", badge), ("badge-experimental", badge)]
