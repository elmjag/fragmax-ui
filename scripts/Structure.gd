extends ColorRect

const utils = preload("res://scripts/utils.gd")

onready var model = get_node("/root/Control/model")


func _ready():
    utils.model_connect(self, "_model_updated")

    var close = get_node("close")
    close.connect("pressed", self, "_on_close_clicked")


func _on_close_clicked():
    model.do(Model.Actions.HIDE_CRYSTAL_STRUCTURE, null)


func _model_updated(state):
    var visible_crystal = state.ui.visible_crystal_structure

    if visible_crystal == null:
        self.visible = false
        return

    self.visible = true
