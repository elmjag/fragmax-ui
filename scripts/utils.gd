static func model_connect(target: Node, method: String):
    var model = target.get_node("/root/Control/model")
    model.connect("model_updated", target, method)


static func remove_elements(elements):
    for element in elements:
        element.queue_free()


class Set:
    var _elements = {}

    func add(element):
        self._elements[element] = true

    func remove(element):
        self._elements.erase(element)

    func contains(element):
        return self._elements.has(element)
