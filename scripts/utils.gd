static func model_connect(target: Node, method: String):
    var model = target.get_node("/root/Control/model")
    model.connect("model_updated", target, method)


static func remove_elements(elements):
    for element in elements:
        element.queue_free()


static func expand_toggle_text(expanded):
    if expanded:
        return "-"

    return "+"


class Set:
    var _elements = {}

    func _init(elements := []):
        for element in elements:
            self.add(element)

    func set_included(element, included: bool):
        if included:
            self.add(element)
            return

        self.remove(element)

    func add(element):
        self._elements[element] = true

    func remove(element):
        self._elements.erase(element)

    func contains(element):
        return self._elements.has(element)

    func is_empty():
        return self._elements.empty()

    func as_list():
        return self._elements.keys()
