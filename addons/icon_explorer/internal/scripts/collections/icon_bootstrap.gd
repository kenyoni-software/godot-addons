extends "res://addons/icon_explorer/internal/scripts/icon.gd"

var tags: PackedStringArray
var categories: PackedStringArray
var version_added: String

func match(keyword: String) -> int:
    var name_match: int = self.get_name_match(keyword)
    if name_match != 0:
        return name_match
    for tag: String in self.tags:
        if tag.to_lower().contains(keyword):
            return 7
    for category: String in self.categories:
        if category.to_lower().contains(keyword):
            return 5
    return 0
