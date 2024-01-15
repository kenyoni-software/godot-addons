extends "res://addons/icon_explorer/internal/scripts/icon.gd"

var hex: Color
var source: String
var aliases: PackedStringArray
var license: String
var license_link: String
var guidelines: String


func match(keyword: String) -> int:
    var name_match: int = self.get_name_match(keyword)
    if name_match != 0:
        return name_match
    for alias: String in self.aliases:
        if alias.to_lower().contains(keyword):
            return 7
    if self.hex.to_html().to_lower() == keyword || "#"+self.hex.to_html().to_lower() == keyword:
        return 1
    return 0
