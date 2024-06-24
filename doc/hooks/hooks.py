import argparse
import re
from re import Match
import shlex
from typing import Callable

from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.files import Files
from mkdocs.structure.pages import Page

import badge
import godot_ref
import source_link


class Parser(argparse.ArgumentParser):
    def __init__(self):
        super().__init__()
        self.subparsers = self.add_subparsers(dest="command", parser_class=argparse.ArgumentParser)

    def error(self, message: str) -> None:
        print(message)


PARSER = Parser()
HOOKS: dict[str, Callable[[argparse.Namespace, MkDocsConfig], str]] = {}


def add_hooks(hook: Callable[[any], list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]]]) -> None:
    hooks: list[tuple[str, Callable[[argparse.Namespace, MkDocsConfig], str]]] = hook(PARSER.subparsers)
    for hook in hooks:
        HOOKS[hook[0]] = hook[1]


add_hooks(badge.HOOKS)
add_hooks(godot_ref.HOOKS)
add_hooks(source_link.HOOKS)


def on_page_markdown(markdown: str, *, page: Page, config: MkDocsConfig, files: Files):
    def replace(match: re.Match):
        args: argparse.Namespace = PARSER.parse_args(shlex.split(match.groups()[0]))

        fn: Callable[[argparse.Namespace, MkDocsConfig], str] = HOOKS.get(args.command, None)
        if fn is None:
            raise RuntimeError(f"Unknown short code: {args.command}")
        return fn(args, config)

    return re.sub(
        r"{{\skny:(.*?)\s}}",
        replace, markdown, flags=re.I | re.M
    )
