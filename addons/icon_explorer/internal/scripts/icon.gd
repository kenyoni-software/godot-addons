extends RefCounted

const Collection := preload("res://addons/icon_explorer/internal/scripts/collection.gd")

var name: String
var collection: Collection
var texture: Texture2D
var icon_path: String
var svg_size: Vector2 = Vector2.ZERO
var colorable: bool = false

# used by the GUI to sort multiple icons, cached value to optimize sorting
var sort_priority: int

# VIRTUAL
# return a value between 0 and 10
# 10:
# - keyword is contained in name
# 7:
# - keyword is part of an alias
# 5:
# - keyword is part of category or search term
# 0:
# - will not be displayed
func match(keyword: String) -> int:
    return 0

# return either 10, 9 or 0
func get_name_match(keyword: String) -> int:
    if self.name.to_lower() == keyword:
        return 10
    if self.name.to_lower().contains(keyword):
        return 9
    if self.name.similarity(keyword) > 0.8:
        return 9
    return 0

static func compare(lhs, rhs) -> bool:
    return lhs.sort_priority > rhs.sort_priority || (lhs.sort_priority == rhs.sort_priority && lhs.name.to_lower() < rhs.name.to_lower())

static var _rx_view_box: RegEx = RegEx.create_from_string(r'viewBox=\"([+-]?(?:[0-9]*[.])?[0-9]+) ([+-]?(?:[0-9]*[.])?[0-9]+) ([+-]?(?:[0-9]*[.])?[0-9]+) ([+-]?(?:[0-9]*[.])?[0-9]+)\"')

static func get_svg_size(buffer: String) -> Vector2:
    # TODO: static init is not called in editor if not @tool
    if _rx_view_box == null:
        _rx_view_box = RegEx.create_from_string(r'viewBox=\"([+-]?(?:[0-9]*[.])?[0-9]+) ([+-]?(?:[0-9]*[.])?[0-9]+) ([+-]?(?:[0-9]*[.])?[0-9]+) ([+-]?(?:[0-9]*[.])?[0-9]+)\"')
    var rx_match: RegExMatch = _rx_view_box.search(buffer)
    if rx_match:
        return Vector2(float(rx_match.get_string(3)) - float(rx_match.get_string(1)), float(rx_match.get_string(4)) - int(rx_match.get_string(2)))
    return Vector2(0, 0)
