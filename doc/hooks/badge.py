import argparse
from typing import Callable

from mkdocs.config.defaults import MkDocsConfig


def _badge_html(args: argparse.Namespace):
    left_classes = f"mdx-badge__icon" if args.left_text[0] == ":" and args.left_text[-1] == ":" else "mdx-badge__text"
    if args.left_bg:
        left_classes += " kny-badge-bg"
    right_classes = f"mdx-badge__icon" if len(args.right_text) > 2 and args.right_text[0] == ":" and args.right_text[-1] == ":" else "mdx-badge__text"
    if args.right_bg:
        right_classes += " kny-badge-bg"
    return "".join([
        f'<span class="mdx-badge">',
        f'<span class="{left_classes}">{args.left_text}</span>' if args.left_text else "",
        f'<span class="{right_classes}">{args.right_text}</span>' if args.right_text else "",
        f"</span>",
    ])


def badge(args: argparse.Namespace, config: MkDocsConfig) -> str:
    if args.command == "badge-version":
        args.left_text = ":material-tag-outline:"
        args.left_bg = True
    if args.command == "badge-experimental":
        args.left_text = ":material-flask-outline:"
        args.left_bg = True
    if args.command == "badge-download":
        args.left_text = ":material-download:"
        args.left_bg = True
    return _badge_html(args)


def HOOKS(sub_parser) -> list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]]:
    parser = sub_parser.add_parser("badge", help="badge")
    parser.add_argument("left_text", type=str, default="", help="left text of the badge")
    parser.add_argument("right_text", nargs='?', type=str, default="", help="right text of the badge")
    parser.add_argument("--left-bg", action="store_true", default=False, help="left background color")
    parser.add_argument("--right-bg", action="store_true", default=False, help="left background color")

    parser: argparse.ArgumentParser = sub_parser.add_parser("badge-version", help="experimental badge")
    parser.add_argument("right_text", type=str, default="", help="right text of the badge")
    parser.add_argument("--right-bg", action="store_true", default=False, help="left background color")

    parser = sub_parser.add_parser("badge-experimental", help="experimental badge")
    parser.add_argument("right_text", type=str, default="", help="right text of the badge")
    parser.add_argument("--right-bg", action="store_true", default=False, help="left background color")

    parser = sub_parser.add_parser("badge-download", help="download badge")
    parser.add_argument("right_text", type=str, default="", help="right text of the badge")
    parser.add_argument("--right-bg", action="store_true", default=False, help="left background color")

    return [("badge", badge), ("badge-version", badge), ("badge-experimental", badge), ("badge-download", badge)]
