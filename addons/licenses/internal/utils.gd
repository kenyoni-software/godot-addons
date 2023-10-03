## will return the property list of object
## if an entry is duplicated the last one is replacing the previous one
static func get_updated_property_list(object: Object) -> Array:
    var properties: Array = object.get_property_list()
    var patched_properties: Array = object._get_property_list()
    properties = properties.slice(0, properties.size() - patched_properties.size())
    for p_prop_idx: int in range(patched_properties.size()):
        for prop_idx: int in range(properties.size()):
            if properties[prop_idx]["name"] == patched_properties[p_prop_idx]["name"]:
                properties[prop_idx] = patched_properties[p_prop_idx]
                break
    return properties
