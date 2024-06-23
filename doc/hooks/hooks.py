import argparse
import re
from re import Match
from typing import Callable

from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.files import Files
from mkdocs.structure.pages import Page

import badge
import source_link


def gen_parser() -> tuple[argparse.ArgumentParser, any]:
    parser = argparse.ArgumentParser()
    parser.exit_on_error = False
    subparsers = parser.add_subparsers(dest="command")

    return parser, subparsers


PARSER, SUB_PARSER = gen_parser()
HOOKS: dict[str, Callable[[argparse.Namespace, MkDocsConfig], str]] = {}


def add_hooks(hook: Callable[[any], list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]]]) -> None:
    hooks: list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]] = hook(SUB_PARSER)
    for hook in hooks:
        HOOKS[hook[0]] = hook[1]


add_hooks(badge.HOOKS)
add_hooks(source_link.HOOKS)


def on_page_markdown(markdown: str, *, page: Page, config: MkDocsConfig, files: Files):
    def replace(match: re.Match):
        args: argparse.Namespace = PARSER.parse_args(match.groups()[0].split(" "))

        fn: Callable[[argparse.Namespace, MkDocsConfig], str] = HOOKS.get(args.command, None)
        if fn is None:
            raise RuntimeError(f"Unknown shortcode: {type}")

        return fn(args, config)

    return re.sub(
        r"{{\skny:(.*?)\s}}",
        replace, markdown, flags=re.I | re.M
    )
