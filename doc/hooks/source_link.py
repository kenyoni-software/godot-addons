import argparse
from typing import Callable

from mkdocs.config.defaults import MkDocsConfig


def source_link(args: argparse.Namespace, config: MkDocsConfig) -> str:
    return f"[{args.path if args.text == '' else args.text}]({config.extra.get('kenyoni', {}).get('source_url', '')}{args.path})"


def HOOKS(sub_parser) -> list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]]:
    parser = sub_parser.add_parser("source")
    parser.add_argument("path", type=str, default="", help="source path")
    parser.add_argument("text", nargs='?', type=str, default="", help="text")

    return [("source", source_link)]
