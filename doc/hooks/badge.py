from typing import Callable

from mkdocs.config.defaults import MkDocsConfig


def _badge_html(icon: str, text: str = "", typ: str = ""):
    classes = f"mdx-badge mdx-badge--{typ}" if typ else "mdx-badge"
    return "".join([
        f'<span class="{classes}">',
        f'<span class="mdx-badge__icon">{icon}</span>' if icon else "",
        f'<span class="mdx-badge__text">{text}</span>' if text else "",
        f"</span>",
    ])


def badge(args_text: str, config: MkDocsConfig) -> str:
    icon, *text = args_text.split(" ", 1)
    return _badge_html(
        icon=icon,
        text="".join(text)
    )


def badge_experimental(_args: str, config: MkDocsConfig):
    return _badge_html(":material-flask-outline:")


def badge_version(args_text: str, config: MkDocsConfig):
    return _badge_html(":material-tag-outline:", f"{args_text}")


HOOKS: dict[str, Callable[[str, MkDocsConfig], str]] = {
    "badge": badge,
    "experimental": badge_experimental,
    "version": badge_version,
}
