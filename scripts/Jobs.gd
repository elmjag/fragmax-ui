extends VBoxContainer

const utils = preload("res://scripts/utils.gd")
const jobs_set_scene = preload("res://scenes/jobs_set_row.tscn")
const active_jobs_list_scene = preload("res://scenes/active_jobs_list.tscn")
const finished_jobs_list_scene = preload("res://scenes/finished_jobs_list.tscn")
const active_job_scene = preload("res://scenes/active_job.tscn")
const finished_job_scene = preload("res://scenes/finished_job.tscn")

onready var model = get_node("/root/Control/model")
onready var active_job_sets_container = get_node("ActiveJobSets")
onready var finished_job_sets_container = get_node("FinishedJobSets")


var added_elemens = []


func _ready():
    utils.model_connect(self, "_model_updated")


func _on_jobs_set_expand_toggle(jobs_set):
    model.do(Model.Actions.TOGGLE_JOBS_SET_EXPAND, jobs_set)


func _add_row(container, row):
    container.add_child(row)
    added_elemens.append(row)


func _get_jobs_set_row(jobs_set, expanded):
    var row = jobs_set_scene.instance()
    var children = row.get_children()
    children[0].connect("pressed", self, "_on_jobs_set_expand_toggle", [jobs_set])
    children[0].text = "-" if expanded else "+"
    children[1].text = jobs_set.description

    return row


func _job_progress_text(status):
    match status:
        Model.JobStatus.ENQUEUED:
            return "enqueued"
        Model.JobStatus.RUNNING:
            return "running"
        Model.JobStatus.DONE:
            return "done"
        Model.JobStatus.FAILED:
            return "failed"
        Model.JobStatus.ABORTED:
            return "aborted"


func _get_active_jobs_list_row(jobs):
    var jobs_node = active_jobs_list_scene.instance()

    for job in jobs:
        var job_node = active_job_scene.instance()
        var children = job_node.get_children()

        children[1].text = job.crystal.id
        children[4].text = _job_progress_text(job.progress)

        jobs_node.add_child(job_node)

    return jobs_node


func _get_finished_jobs_list_row(jobs):
    var jobs_node = finished_jobs_list_scene.instance()

    for job in jobs:
        var job_node = finished_job_scene.instance()
        var children = job_node.get_children()

        children[0].text = job.crystal.id
        children[3].text = _job_progress_text(job.progress)

        jobs_node.add_child(job_node)

    return jobs_node


func _add_active_job_sets(job_sets, expanded_job_sets):
    for jobs_set in job_sets:
        var expanded = expanded_job_sets.contains(jobs_set)
        var row =_get_jobs_set_row(jobs_set, expanded)

        _add_row(active_job_sets_container, row)

        if expanded:
            _add_row(active_job_sets_container,
                     _get_active_jobs_list_row(jobs_set.jobs))


func _add_finished_job_sets(job_sets, expanded_job_sets):
    for jobs_set in job_sets:
        var expanded = expanded_job_sets.contains(jobs_set)
        var row =_get_jobs_set_row(jobs_set, expanded)

        _add_row(finished_job_sets_container, row)

        if expanded:
            _add_row(finished_job_sets_container,
                     _get_finished_jobs_list_row(jobs_set.jobs))


func _model_updated(state):

    utils.remove_elements(added_elemens)
    added_elemens = []

    _add_active_job_sets(state.active_job_sets, state.ui.expanded_job_sets)
    _add_finished_job_sets(state.finished_job_sets, state.ui.expanded_job_sets)
