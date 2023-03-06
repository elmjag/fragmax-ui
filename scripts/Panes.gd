extends Control

const utils = preload("res://scripts/utils.gd")

var pane = null

func _ready():
    utils.model_connect(self, "_model_updated")


func _model_updated(state):
    var new_pane = state.ui.current_pane

    if pane != null:
        pane.visible = false

    pane = get_node(new_pane)
    pane.visible = true
