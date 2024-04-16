extends "res://addons/icon_explorer/internal/scripts/icon.gd"

var aliases: PackedStringArray
var tags: PackedStringArray
var author: String
var version: String
var deprecated: bool


func match(keyword: String) -> int:
    var name_match: int = self.get_name_match(keyword)
    if name_match != 0:
        return name_match
    for alias: String in self.aliases:
        if alias.to_lower().contains(keyword):
            return 7
    for tag: String in self.tags:
        if tag.to_lower().contains(keyword):
            return 7
    if keyword == "deprecated" && self.deprecated:
        return 1
    return 0
