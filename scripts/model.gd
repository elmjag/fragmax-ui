extends Node

class_name Model

signal model_updated(state)

enum Actions {
    SELECT_PANE,
    TOGGLE_SAMPLE_EXPAND,
    SWITCH_SAMPLE_OPTION,
}

const utils = preload("res://scripts/utils.gd")

class UI:
    var expanded_samples = utils.Set.new()
    var current_pane = "Samples"


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
    var ui = UI.new()

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


func do(action, arg):
    match action:
        Actions.SELECT_PANE:
            state.ui.current_pane = arg
        Actions.TOGGLE_SAMPLE_EXPAND:
            _toggle_sample_expand(arg)
        Actions.SWITCH_SAMPLE_OPTION:
            arg.crystal.selected = arg.option

    self.call_deferred("_emit_model_updated_signal")

