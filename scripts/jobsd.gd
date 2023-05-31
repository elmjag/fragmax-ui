extends Node

const utils = preload("res://scripts/utils.gd")

onready var model = get_node("/root/Control/model")

var running_job_sets = utils.Set.new()


func _ready():
    utils.model_connect(self, "_model_updated")


func _model_updated(state):
    for jobs_set in state.active_job_sets:
        if running_job_sets.contains(jobs_set):
            continue

        _run_jobs_set(jobs_set)


func _get_next_progress_state(job):
    match job.progress:
        Model.JobStatus.ENQUEUED:
            return Model.JobStatus.RUNNING
        Model.JobStatus.RUNNING:
            return Model.JobStatus.DONE

    return job.progress


func _progress_job(jobs_set, job):
    var next_state = _get_next_progress_state(job)

    model.do(Model.Actions.SET_JOB_PROGRESS,
             [jobs_set, job, next_state])


func _run_jobs_set(jobs_set):
    running_job_sets.add(jobs_set)

    for job in jobs_set.jobs:
        yield(get_tree().create_timer(0.305), "timeout")
        _progress_job(jobs_set, job)

    running_job_sets.remove(jobs_set)
