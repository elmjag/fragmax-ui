extends VBoxContainer


const utils = preload("res://scripts/utils.gd")
var row_scene = preload("res://scenes/sample_row.tscn")
onready var model = get_node("/root/Control/model")
var added_elemens = []


func _ready():
    utils.model_connect(self, "_model_updated")


func _selected_desc(selected, desc={}):
    if not desc:
        desc = {
            "dataset": "",
            "proc_res": "",
            "refine_res": "",
        }

    match selected.type:
        "DataSet":
            desc["dataset"] = selected
            return desc
        "ProcResult":
            desc["proc_res"] = selected.tool_name
            return _selected_desc(selected.input, desc)
        "RefineResult":
            desc["refine_res"] = selected.tool_name
            return _selected_desc(selected.input, desc)


func _on_sample_expand_toggle(crystal_id):
    model.do(Model.Actions.TOGGLE_SAMPLE_EXPAND, crystal_id)


func _get_row(crystal, expanded):
    var desc = _selected_desc(crystal.selected)
    var dataset = desc["dataset"]

    var row = row_scene.instance()
    var children = row.get_children()

    children[0].text = "-" if expanded else "+"
    children[0].connect("pressed", self, "_on_sample_expand_toggle", [crystal.id])
    children[1].text = crystal.id
    children[2].text = str(dataset.run)
    children[3].text = desc["proc_res"]
    children[4].text = desc["refine_res"]
    children[5].text = str(dataset.resolution)

    return row


func _model_updated(state):
    utils.remove_elements(added_elemens)
    added_elemens = []

    for crystal in state.crystals:
        var expanded = state.ui.expanded_samples.contains(crystal.id)
        print("crystal " + crystal.id + " " + str(expanded))
        var row = _get_row(crystal, expanded)
        add_child(row)
        added_elemens.append(row)
