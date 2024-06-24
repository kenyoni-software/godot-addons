import argparse
from typing import Callable

from mkdocs.config.defaults import MkDocsConfig


def godot_ref(args: argparse.Namespace, config: MkDocsConfig) -> str:
    return f'<a class="kny-godot-ref" href="https://docs.godotengine.org/en/stable/classes/class_{args.class_name.lower()}.html">{args.class_name}</a>'


def HOOKS(sub_parser) -> list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]]:
    parser = sub_parser.add_parser("godot")
    parser.add_argument("class_name", type=str, default="", help="class name")

    return [("godot", godot_ref)]
