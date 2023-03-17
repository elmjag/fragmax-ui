const utils = preload("res://scripts/utils.gd")


static func _proc_crystal_desc(crystal):
    var desc = {
        "crystal_id": crystal.id,
        "dataset": "",
        "proc_res": {"name": "", "success": true},
        "status": "unprocessed",
    }

    var selected = crystal.selected

    match selected.type:
        "DataSet":
            desc["dataset"] = selected
        "ProcResult":
            desc["dataset"] = selected.input
            desc["proc_res"] = {"name": selected.tool_name, "success": selected.success}
            if selected.success:
                desc.status = "processed"
            else:
                desc.status = "failure"
        "RefineResult":
            desc["dataset"] = selected.input.input
            desc["proc_res"] = {"name": selected.input.tool_name, "success": selected.input.success}
            if selected.input.success:
                desc.status = "processed"
            else:
                desc.status = "failure"

    return desc


static func _proc_sample_visible(state, desc):
    # text filter
    var text_filter = state.ui.process.text_filter
    if text_filter != "" and not (text_filter in desc.crystal_id):
        return false

    # session filter
    if not state.ui.process.visible_sessions.contains(desc.dataset.session):
        return false

    # tools filter
    var tool_name = desc.proc_res.name
    if tool_name != "":
        if not state.ui.process.visible_tools.contains(tool_name):
            return false

    # status filter
    if not state.ui.process.visible_status.contains(desc.status):
        return false

    return true


static func get_proc_visisble_samples(state):
    var visisble = []

    for crystal in state.crystals:
        var desc = _proc_crystal_desc(crystal)
        if _proc_sample_visible(state, desc):
            visisble.append(desc)

    return visisble


static func get_sessions(state):
    var sessions = utils.Set.new()

    for crystal in state.crystals:
        for dataset in crystal.datasets:
            sessions.add(dataset.session)

    return sessions.as_list()


static func get_selected_process_tool(state):
    var process = state.ui.process
    return process.tools[process.selected_tool_idx]
