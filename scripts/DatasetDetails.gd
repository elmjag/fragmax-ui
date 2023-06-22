extends ColorRect

const utils = preload("res://scripts/utils.gd")

onready var model = get_node("/root/Control/model")
onready var crystal = get_node("info/crystal")
onready var run = get_node("info/run")


func _ready():
    utils.model_connect(self, "_model_updated")

    var close = get_node("close")
    close.connect("pressed", self, "_on_close_clicked")


func _on_close_clicked():
    model.do(Model.Actions.HIDE_DATASET_DETAILS, null)


func _model_updated(state):
    var visible_dataset_details = state.ui.visible_dataset_details

    if visible_dataset_details == null:
        self.visible = false
        return


    crystal.text = visible_dataset_details[0]
    run.text = str(visible_dataset_details[1])

    self.visible = true
