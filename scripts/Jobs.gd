extends VBoxContainer

const utils = preload("res://scripts/utils.gd")
const jobs_set_scene = preload("res://scenes/jobs_set_row.tscn")
const jobs_list_scene = preload("res://scenes/jobs_list.tscn")
const job_scene = preload("res://scenes/job.tscn")

onready var model = get_node("/root/Control/model")
onready var job_sets_container = get_node("JobSets")

var added_elemens = []

func _ready():
    utils.model_connect(self, "_model_updated")


func _on_jobs_set_expand_toggle(jobs_set):
    model.do(Model.Actions.TOGGLE_JOBS_SET_EXPAND, jobs_set)


func _add_row(row):
    job_sets_container.add_child(row)
    added_elemens.append(row)


func _get_jobs_set_row(jobs_set, expanded):
    var row = jobs_set_scene.instance()
    var children = row.get_children()
    children[0].connect("pressed", self, "_on_jobs_set_expand_toggle", [jobs_set])
    children[0].text = "-" if expanded else "+"
    children[1].text = jobs_set.description

    return row


func _get_jobs_list_row(jobs):
    var jobs_node = jobs_list_scene.instance()

    for job in jobs:
        var job_node = job_scene.instance()
        var children = job_node.get_children()

        children[1].text = job.crystal.id
        children[1].text = job.progress

        jobs_node.add_child(job_node)

    return jobs_node


func _add_job_sets(job_sets, expanded_job_sets):
    for jobs_set in job_sets:
        var expanded = expanded_job_sets.contains(jobs_set)
        var row =_get_jobs_set_row(jobs_set, expanded)

        _add_row(row)

        if expanded:
            _add_row(_get_jobs_list_row(jobs_set.jobs))


func _model_updated(state):

    utils.remove_elements(added_elemens)
    added_elemens = []

    _add_job_sets(state.jobSets, state.ui.expanded_job_sets)
