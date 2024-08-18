extends "res://addons/icon_explorer/internal/scripts/icon.gd"

var category: String
var tags: PackedStringArray
var version: String

func match(keyword: String) -> int:
    var name_match: int = self.get_name_match(keyword)
    if name_match != 0:
        return name_match
    for tag: String in self.tags:
        if tag.to_lower().contains(keyword):
            return 7
    if self.category.to_lower().contains(keyword):
        return 5
    return 0
