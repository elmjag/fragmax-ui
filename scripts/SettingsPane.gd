extends VBoxContainer

const utils = preload("res://scripts/utils.gd")

onready var model = get_node("/root/Control/model")
onready var crystal_picture = get_node("SamplesViewOpts/Options/CrystalPicture/CheckBox")
onready var dozer_graph = get_node("SamplesViewOpts/Options/DozerGraph/CheckBox")
onready var proc_space_group = get_node("SamplesViewOpts/Options/ProcSpaceGroup/CheckBox")
onready var proc_multiplicity = get_node("SamplesViewOpts/Options/ProcMultiplicity/CheckBox")
onready var ref_resolution = get_node("SamplesViewOpts/Options/RefResolution/CheckBox")
onready var ref_rwork = get_node("SamplesViewOpts/Options/RefRwork/CheckBox")


func _ready():
    utils.model_connect(self, "_model_updated")

    crystal_picture.connect("toggled", self, "_on_toggled", ["crystal_picture"])
    dozer_graph.connect("toggled", self, "_on_toggled", ["dozer_graph"])
    proc_space_group.connect("toggled", self, "_on_toggled", ["proc_space_group"])
    proc_multiplicity.connect("toggled", self, "_on_toggled", ["proc_multiplicity"])
    ref_resolution.connect("toggled", self, "_on_toggled", ["ref_resolution"])
    ref_rwork.connect("toggled", self, "_on_toggled", ["ref_rwork"])


func _on_toggled(selected, name):
    model.do(Model.Actions.UPDATE_SETTINGS, [name, selected])


func _model_updated(state):
    var show = state.ui.settings.show

    crystal_picture.pressed = show.crystal_picture
    dozer_graph.pressed = show.dozer_graph
    proc_space_group.pressed = show.proc_space_group
    proc_multiplicity.pressed = show.proc_multiplicity
    ref_resolution.pressed = show.ref_resolution
    ref_rwork.pressed = show.ref_rwork
