from typing import Callable

from mkdocs.config.defaults import MkDocsConfig


def source_link(args: str, config: MkDocsConfig) -> str:
    path, *text_ = args.split(" ", 1)
    text: str = "".join(text_)
    print(config.extra["kenyoni"])
    return f"[{path if text == '' else text}]({config.extra.get('kenyoni', {}).get('source_url', '')}{path})"


HOOKS: dict[str, Callable[[str, MkDocsConfig], str]] = {
    "source": source_link,
}
