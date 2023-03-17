extends Node

class_name Model

signal model_updated(state)

enum Actions {
    SELECT_PANE,
    TOGGLE_SAMPLE_EXPAND,
    SWITCH_SAMPLE_OPTION,

    # 'Samples' section on 'Processing' page
    TOGGLE_SAMPLES_EXPANDED,

    # sample selection/deselected on 'Processing' page
    SET_PROC_SAMPLE_SELECTED,

    # text filter on 'Processing' page
    SET_PROC_TEXT_FILTER,

    # sessions filter on 'Processing' page
    SET_PROC_SESSION_FILTER,

    # tools filter on 'Processing' page
    SET_PROC_TOOL_FILTER,

    # status filter on 'Processing' page
    SET_PROC_STATUS_FILTER,

    # select/unselect all visible samples on 'Processing' page
    TOGGLE_PROC_VISIBLE_SAMPLES_SELECTED,

    # set selected processing tool on 'Processing' page
    SET_PROC_TOOL,

    PROCESS_SELECTED_SAMPLES,
}

const utils = preload("res://scripts/utils.gd")
const state_views = preload("res://scripts/state_views.gd")

# Data Analysis -> Process pane state
class ProcessUI:
    var samples_expanded = true
    var text_filter = ""
    var selected_samples = utils.Set.new()
    var visible_sessions = utils.Set.new()
    var tools = ["EDNA_proc", "XIA2/DIALS", "XIA2/XDS", "XDSAPP"]
    var selected_tool_idx = 0
    var visible_tools = utils.Set.new()
    var visible_status = utils.Set.new(["unprocessed", "processed", "failure"])


class UI:
    var current_pane = "Samples"
    var expanded_samples = utils.Set.new()
    var process = ProcessUI.new()


class RefineResult:
    var type = "RefineResult"
    var tool_name: String
    var success: bool

    # input ProcResult used to generate this refine result
    var input

    func _init(tool_name, success):
        self.tool_name = tool_name
        self.success = success

    func set_input(input):
        self.input = input

    func _to_string():
        return "|RefineResult " + self.tool_name + "|"


class ProcResult:
    var type = "ProcResult"
    var tool_name: String
    var success: bool
    var results

    # input DataSet used to generate this proc result
    var input

    func _init(tool_name, success, results):
        self.tool_name = tool_name
        self.success = success
        self.results = results

        for res in results:
            res.set_input(self)

    func set_input(input):
        self.input = input

    func get_default_selected():
        if len(self.results) > 0:
            return self.results[0]

        # no refine results
        return null

    func _to_string():
        return "|ProcResult " + self.tool_name + "|"


class DataSet:
    var type = "DataSet"
    var run: int
    var session: String
    var resolution: float
    var results

    var crystal

    func _init(run, session, resolution, results):
        self.run = run
        self.session = session
        self.resolution = resolution
        self.results = results

        for res in results:
            res.set_input(self)

    func set_crystal(crystal):
        self.crystal = crystal

    func get_default_selected():
        for proc_res in self.results:
            var res = proc_res.get_default_selected()
            if res:
                return res

        # no refine result for this dataset
        if len(self.results) > 0:
            # use first proc result
            return self.results[0]

        return null

    func _to_string():
        return "|DataSet " + self.crystal.id + "-" + str(self.run) + "|"



class Crystal:
    var type = "Crystal"
    var id: String
    var datasets = []

    # points to currently selected 'result' from this crystal,
    # if there is no result for this crystal yet, points to selected dataset
    var selected = null

    func get_default_selected():
        for dset in self.datasets:
            var res = dset.get_default_selected()
            if res:
                return res

        # no results for this crystal, use first dataset
        assert(len(self.datasets) > 0)
        return self.datasets[0]

    func _init(id, datasets):
        self.id = id
        self.datasets = datasets

        for dset in datasets:
            dset.set_crystal(self)

        self.selected = self.get_default_selected()

    func _to_string():
        return "|Crystal " + self.id + "|"


class State:
    var ui = UI.new()
    var crystals = [
        Crystal.new("MtCM-x0001", [
            DataSet.new(1, "20220611", 1.8,
            [
                ProcResult.new("XDSAPP", false, []),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
        Crystal.new("MtCM-x0002", [
            DataSet.new(1, "20220611", 1.8,
            [
                ProcResult.new("XDSAPP", true,
                [
                    RefineResult.new("DIMPLE", false),
                ]),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
        Crystal.new("MtCM-x0007", [
            DataSet.new(1, "20220611", 1.8, []),
            DataSet.new(2, "20220611", 1.8, []),
        ]),
        Crystal.new("MtCM-x0008", [
            DataSet.new(1, "20220611", 1.8,
            [
                ProcResult.new("XDSAPP", true,
                [
                    RefineResult.new("DIMPLE", true),
                ]),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
        Crystal.new("MtCM-x0009", [
            DataSet.new(1, "20220611", 1.8,
            [
                ProcResult.new("XDSAPP", true,
                [
                    RefineResult.new("DIMPLE", true),
                ]),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
        Crystal.new("MtCM-x0080", [
            DataSet.new(1, "20230225", 1.8,
            [
                ProcResult.new("XDSAPP", true,
                [
                    RefineResult.new("DIMPLE", true),
                ]),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
        Crystal.new("MtCM-x0081", [
            DataSet.new(1, "20230225", 1.8,
            [
                ProcResult.new("XDSAPP", false, []),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
        Crystal.new("MtCM-x0082", [
            DataSet.new(1, "20230225", 1.8,
            [
                ProcResult.new("XDSAPP", false, []),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
        Crystal.new("MtCM-x0083", [
            DataSet.new(1, "20230225", 1.8,
            [
                ProcResult.new("XDSAPP", true, []),
                ProcResult.new("EDNA_proc", false, []),
            ]),
            DataSet.new(2, "20230225", 1.8,
            [
                ProcResult.new("XDSAPP", false, []),
                ProcResult.new("EDNA_proc", false, []),
            ]),
        ]),
    ]

    func _init():
        # start with all sessions visible
        for session in self.get_sessions():
            self.ui.process.visible_sessions.add(session)

        # start with all tools visible
        for tool_name in self.ui.process.tools:
            self.ui.process.visible_tools.add(tool_name)


    #
    # short-cut views of the state
    #

    #
    # get all sessions listed for crystal datasets
    #
    func get_sessions():
        return state_views.get_sessions(self)

    #
    # get currently visible samples according to filters
    # on 'Processing' page
    #
    func get_proc_visisble_samples():
        return state_views.get_proc_visisble_samples(self)


    func get_selected_process_tool():
        return state_views.get_selected_process_tool(self)


var state = State.new()


func _emit_model_updated_signal():
    emit_signal("model_updated", state)


func _ready():
    self.call_deferred("_emit_model_updated_signal")


func _toggle_sample_expand(crystal_id):
    var expanded_set = state.ui.expanded_samples

    if expanded_set.contains(crystal_id):
        expanded_set.remove(crystal_id)
    else:
        expanded_set.add(crystal_id)


func _set_proc_sample_selected(crystal_id, selected):
    state.ui.process.selected_samples.set_included(crystal_id, selected)


func _toggle_proc_visible_samples_selected(selected: bool):
    for desc in state.get_proc_visisble_samples():
        state.ui.process.selected_samples.set_included(desc.crystal_id, selected)


func _set_proc_session_filter(session, show: bool):
    state.ui.process.visible_sessions.set_included(session, show)


func _set_proc_tool_filter(tool_name, show: bool):
    state.ui.process.visible_tools.set_included(tool_name, show)


func _set_proc_status_filter(status, show: bool):
    state.ui.process.visible_status.set_included(status, show)


func _process_selected_samples():
    var process = state.ui.process

    var tool_name = state.get_selected_process_tool()
    print("process with %s" % tool_name)

    for sample in process.selected_samples.as_list():
        print(sample)


func do(action, arg):
    match action:
        Actions.SELECT_PANE:
            state.ui.current_pane = arg
        Actions.TOGGLE_SAMPLE_EXPAND:
            _toggle_sample_expand(arg)
        Actions.SWITCH_SAMPLE_OPTION:
            arg.crystal.selected = arg.option
        Actions.TOGGLE_SAMPLES_EXPANDED:
            state.ui.process.samples_expanded = !state.ui.process.samples_expanded
        Actions.SET_PROC_TEXT_FILTER:
            state.ui.process.text_filter = arg
        Actions.SET_PROC_SAMPLE_SELECTED:
            _set_proc_sample_selected(arg[0], arg[1])
        Actions.TOGGLE_PROC_VISIBLE_SAMPLES_SELECTED:
            _toggle_proc_visible_samples_selected(arg)
        Actions.SET_PROC_SESSION_FILTER:
            _set_proc_session_filter(arg[0], arg[1])
        Actions.SET_PROC_TOOL_FILTER:
            _set_proc_tool_filter(arg[0], arg[1])
        Actions.SET_PROC_STATUS_FILTER:
            _set_proc_status_filter(arg[0], arg[1])
        Actions.SET_PROC_TOOL:
            state.ui.process.selected_tool_idx = arg
        Actions.PROCESS_SELECTED_SAMPLES:
            _process_selected_samples()


    self.call_deferred("_emit_model_updated_signal")

