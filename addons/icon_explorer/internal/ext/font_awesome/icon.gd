extends "res://addons/icon_explorer/internal/scripts/icon.gd"

var style: String
var aliases: PackedStringArray
var search_terms: PackedStringArray

func match(keyword: String) -> int:
    var name_match: int = self.get_name_match(keyword)
    if name_match != 0:
        return name_match
    for alias: String in self.aliases:
        if alias.to_lower().contains(keyword):
            return 7
    for term: String in self.search_terms:
        if term.to_lower().contains(keyword):
            return 5
    if self.style.to_lower().contains(keyword):
        return 3
    return 0
