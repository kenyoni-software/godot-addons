extends "res://addons/icon_explorer/internal/scripts/icon.gd"

var country_code: String

func match(keyword: String) -> int:
    var name_match: int = self.get_name_match(keyword)
    if name_match != 0:
        return name_match
    if self.country_code.to_lower().contains(keyword):
        return 5
    return 0
