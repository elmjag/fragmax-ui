extends VBoxContainer

const utils = preload("res://scripts/utils.gd")
const row_scene = preload("res://scenes/proc_sample_row.tscn")

onready var model = get_node("/root/Control/model")
onready var samples_expand_toggle = get_node("SamplesHeader/expand")
onready var samples = get_node("Samples")
onready var text_filter = get_node("Samples/SamplesSelection/text")
onready var sessions_filter = get_node("Samples/SamplesSelection/sessions").get_popup()
onready var tools_filter = get_node("Samples/SamplesSelection/tools").get_popup()
onready var status_filter = get_node("Samples/SamplesSelection/status").get_popup()
onready var proc_tool = get_node("Tool/tool")
onready var process_button = get_node("ProcessButton/Process")

var added_elemens = []

func _ready():
    utils.model_connect(self, "_model_updated")
    samples_expand_toggle.connect("pressed", self, "_on_samples_expand_toggle")

    text_filter.connect("text_changed", self, "_on_text_filter_changed")

    sessions_filter.hide_on_checkable_item_selection = false
    sessions_filter.connect("index_pressed", self, "_on_sessions_filter_toggle")

    tools_filter.hide_on_checkable_item_selection = false
    tools_filter.connect("index_pressed", self, "_on_tools_filter_toggle")

    status_filter.hide_on_checkable_item_selection = false
    status_filter.connect("index_pressed", self, "_on_status_filter_toggle")
    status_filter.add_check_item("unprocessed")
    status_filter.add_check_item("processed")
    status_filter.add_check_item("failure")

    var select_all = get_node("Samples/SamplesSelection/selectAll")
    select_all.connect("toggled", self, "_on_select_all_toggle")

    proc_tool.connect("item_selected", self, "_on_proc_tool_selected")

    process_button.connect("pressed", self, "_on_process_pressed")


func _on_select_all_toggle(selected):
    model.do(Model.Actions.TOGGLE_PROC_VISIBLE_SAMPLES_SELECTED, selected)


func _on_text_filter_changed(new_text):
    model.do(Model.Actions.SET_PROC_TEXT_FILTER, new_text)


func _on_samples_expand_toggle():
    model.do(Model.Actions.TOGGLE_SAMPLES_EXPANDED, null)


func _on_sessions_filter_toggle(index):
    var session = sessions_filter.get_item_text(index)
    var include = not sessions_filter.is_item_checked(index)

    model.do(Model.Actions.SET_PROC_SESSION_FILTER, [session, include])


func _on_tools_filter_toggle(index):
    var tool_name = tools_filter.get_item_text(index)
    var include = not tools_filter.is_item_checked(index)

    model.do(Model.Actions.SET_PROC_TOOL_FILTER, [tool_name, include])


func _on_status_filter_toggle(index):
    var status = status_filter.get_item_text(index)
    var include = not status_filter.is_item_checked(index)

    model.do(Model.Actions.SET_PROC_STATUS_FILTER, [status, include])


func _sample_selection_toggled(selected, crystal_id):
    model.do(Model.Actions.SET_PROC_SAMPLE_SELECTED, [crystal_id, selected])


func _on_proc_tool_selected(index: int):
    model.do(Model.Actions.SET_PROC_TOOL, index)


func _on_process_pressed():
    model.do(Model.Actions.PROCESS_SELECTED_SAMPLES, null)


func _get_row(desc, selected):
    var dataset = desc.dataset

    var row = row_scene.instance()
    var children = row.get_children()

    children[0].pressed = selected
    children[0].connect("toggled", self, "_sample_selection_toggled", [desc.crystal_id])
    children[1].text = desc.crystal_id
    children[2].text = str(dataset.run)
    children[3].text = dataset.session
    children[4].text = desc.proc_res.name
    if not desc.proc_res.success:
        children[4].add_color_override("font_color", Color.crimson)


    return row


func _add_row(row):
    samples.add_child(row)
    added_elemens.append(row)


func _update_sessions_filter(state):
    #
    # session filter
    #
    sessions_filter.clear()

    var visible_sessions = state.ui.process.visible_sessions

    for session in state.get_sessions():
        sessions_filter.add_check_item(session)

    for i in range(0, sessions_filter.get_item_count()):
        var session = sessions_filter.get_item_text(i)
        sessions_filter.set_item_checked(i, visible_sessions.contains(session))


func _update_tools_filter(state):
    tools_filter.clear()

    var visible_tools = state.ui.process.visible_tools

    for tool_name in state.ui.process.tools:
        tools_filter.add_check_item(tool_name)

    for i in range(0, tools_filter.get_item_count()):
        var tool_name = tools_filter.get_item_text(i)
        tools_filter.set_item_checked(i, visible_tools.contains(tool_name))


func _update_status_filter(state):
    var visisble_status = state.ui.process.visible_status

    for i in range(0, status_filter.get_item_count()):
        var name = status_filter.get_item_text(i)
        status_filter.set_item_checked(i, visisble_status.contains(name))


func _update_samples_section(state):
    var process_ui = state.ui.process
    var expanded = process_ui.samples_expanded

    samples_expand_toggle.text = utils.expand_toggle_text(expanded)
    samples.visible = expanded

    if not expanded:
        # we are done
        return

    _update_sessions_filter(state)
    _update_tools_filter(state)
    _update_status_filter(state)
    text_filter.grab_focus()

    #
    # samples list
    #

    utils.remove_elements(added_elemens)
    added_elemens = []

    var visible_samples = state.get_proc_visisble_samples()
    for desc in visible_samples:
        var selected = process_ui.selected_samples.contains(desc.crystal_id)
        _add_row(_get_row(desc, selected))


func _update_processing_section(state):
    proc_tool.clear()

    for tool_name in state.ui.process.tools:
        proc_tool.add_item(tool_name)

    proc_tool.select(state.ui.process.selected_tool_idx)


func _model_updated(state):
    _update_samples_section(state)
    _update_processing_section(state)

    process_button.disabled = state.ui.process.selected_samples.is_empty()
