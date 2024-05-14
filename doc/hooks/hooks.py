import re
from re import Match
from typing import Callable

from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.files import Files
from mkdocs.structure.pages import Page

import badge
import source_link


HOOKS: dict[str, Callable[[str, MkDocsConfig], str]] = badge.HOOKS | source_link.HOOKS


def on_page_markdown(markdown: str, *, page: Page, config: MkDocsConfig, files: Files):
    def replace(match: Match):
        typ, args = match.groups()
        args = args.strip()

        fn: Callable[[str, MkDocsConfig], str] = HOOKS.get(typ, None)
        if fn is None:
            raise RuntimeError(f"Unknown shortcode: {type}")

        return fn(args, config)

    return re.sub(
        r"<!-- kny:(\w+)(.*?) -->",
        replace, markdown, flags=re.I | re.M
    )
