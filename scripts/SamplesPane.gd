extends VBoxContainer


const utils = preload("res://scripts/utils.gd")
const row_scene = preload("res://scenes/sample_row.tscn")
const row_option_scene = preload("res://scenes/sample_row_option.tscn")

onready var model = get_node("/root/Control/model")
onready var proc_space_group = get_node("Headers/spaceGroup")
onready var proc_multiplicity = get_node("Headers/multiplicity")
onready var resolution = get_node("Headers/resolution")
onready var rwork = get_node("Headers/rwork")
onready var picture = get_node("Headers/picture")
onready var structure = get_node("Headers/structure")
onready var dozer_graph = get_node("Headers/dozer")

var added_elemens = []


func _ready():
    utils.model_connect(self, "_model_updated")


func _selected_desc(selected, desc={}):
    if not desc:
        desc = {
            "dataset": "",
            "proc_res": null,
            "refine_res": null,
        }

    match selected.type:
        "DataSet":
            desc["dataset"] = selected
            return desc
        "ProcResult":
            desc["proc_res"] = {
                "name": selected.tool_name,
                "success": selected.success,
                "space_group": selected.space_group,
                "multiplicity": selected.multiplicity,
            }
            return _selected_desc(selected.input, desc)
        "RefineResult":
            desc["refine_res"] = {
                "name": selected.tool_name,
                "success": selected.success,
                "resolution": selected.resolution,
                "rwork": selected.rwork,
            }
            return _selected_desc(selected.input, desc)


func _on_sample_expand_toggle(crystal_id):
    model.do(Model.Actions.TOGGLE_SAMPLE_EXPAND, crystal_id)


func _on_sample_option_toggled(pressed, crystal, option):
    if not pressed:
        return

    model.do(Model.Actions.SWITCH_SAMPLE_OPTION, {"crystal":crystal, "option":option})


func _on_structure_click(event, crystal_id):
    if not (event is InputEventMouseButton):
        # not a mouse click, ignore
        return

    if event.button_index != 1 or event.pressed:
        # not a 'button 1' click, ignore
        return

    model.do(Model.Actions.SHOW_CRYSTAL_STRUCTURE, crystal_id)


func _on_crystal_details(crystal_id, dataset_run):
    model.do(Model.Actions.SHOW_DATASET_DETAILS, [crystal_id, dataset_run])


func _get_row(crystal, expanded, show):
    var desc = _selected_desc(crystal.selected)

    var dataset = desc["dataset"]

    var row = row_scene.instance()
    var children = row.get_children()

    children[0].text = utils.expand_toggle_text(expanded)
    children[0].connect("pressed", self, "_on_sample_expand_toggle", [crystal.id])

    children[1].connect("pressed", self, "_on_crystal_details", [crystal.id, dataset.run])
    children[1].text = crystal.id
    children[2].text = str(dataset.run)

    var proc_res = desc.proc_res
    if proc_res != null:
        # tool name
        children[3].text = proc_res.name
        if not proc_res.success:
            children[3].add_color_override("font_color", Color.crimson)
        children[5].text = proc_res.space_group
        children[6].text = proc_res.multiplicity

    var refine_res = desc.refine_res
    if refine_res != null:
        children[4].text = refine_res.name
        if refine_res.success:
            children[7].text = str(refine_res.resolution)
            children[8].text = refine_res.rwork
        else:
            children[4].add_color_override("font_color", Color.crimson)


    # process space group
    children[5].visible = show.proc_space_group

    # process multiplicity
    children[6].visible = show.proc_multiplicity

    # resolution
    children[7].visible = show.ref_resolution

    # r_work
    children[8].visible = show.ref_rwork

    # structure
    children[9].visible = show.structure
    children[9].connect("gui_input", self, "_on_structure_click", [crystal.id])


    # picture
    children[10].visible = show.crystal_picture

    # dozer
    children[11].visible = show.dozer_graph

    return row


func _get_option_row(crystal, button_group, option):
    var desc = _selected_desc(option)
    var dataset = desc["dataset"]

    var row = row_option_scene.instance()
    var children = row.get_children()

    children[0].set_button_group(button_group)
    children[0].pressed = (crystal.selected == option)
    children[0].connect("toggled", self, "_on_sample_option_toggled", [crystal, option])
    children[1].text = crystal.id
    children[1].connect("pressed", self, "_on_crystal_details", [crystal.id, dataset.run])
    children[2].text = str(dataset.run)

    if desc.proc_res != null:
        children[3].text = desc.proc_res.name
        if not desc.proc_res.success:
            children[3].add_color_override("font_color", Color.crimson)

    if desc.refine_res != null:
        children[4].text = desc.refine_res.name
        if not desc.refine_res.success:
            children[4].add_color_override("font_color", Color.crimson)

    return row


func _get_leafs(node):
    var leafs = []
    match node.type:
        "Crystal":
            for dset in node.datasets:
                leafs += _get_leafs(dset)
        "DataSet":
            for res in node.results:
                leafs += _get_leafs(res)
        "ProcResult":
            for res in node.results:
                leafs += _get_leafs(res)
        "RefineResult":
            # refine results are always leafs
            pass

    if len(leafs) <= 0:
        # we are the leaf
        leafs = [node]

    return leafs


func _add_row(row):
    add_child(row)
    added_elemens.append(row)


func _update_visible_col_headers(show):
    proc_space_group.visible = show.proc_space_group
    proc_multiplicity.visible = show.proc_multiplicity
    resolution.visible = show.ref_resolution
    rwork.visible = show.ref_rwork
    structure.visible = show.structure
    picture.visible = show.crystal_picture
    dozer_graph.visible = show.dozer_graph


func _model_updated(state):
    var show_cols = state.ui.settings.show

    _update_visible_col_headers(show_cols)

    utils.remove_elements(added_elemens)
    added_elemens = []

    for crystal in state.crystals:
        var expanded = state.ui.expanded_samples.contains(crystal.id)
        _add_row(_get_row(crystal, expanded, show_cols))

        if expanded:
            var button_group = ButtonGroup.new()
            for leaf in _get_leafs(crystal):
                _add_row(_get_option_row(crystal, button_group, leaf))
