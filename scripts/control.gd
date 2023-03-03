extends Control

var panes = {}
var sub_menus = {}
var sample_options = {}

func _ready():
    panes["Samples"] = get_node("ColorRect/Panes/SamplesPane")
    panes["DataAnalysis"] = get_node("ColorRect/Panes/DataAnalysisPane")
    panes["Project"] = get_node("ColorRect/Panes/ProjectPane")
    panes["PanDDA"] = get_node("ColorRect/Panes/PanDDAPane")
    panes["Results"] = get_node("ColorRect/Panes/ResultsPane")
    panes["Libraries"] = get_node("ColorRect/Panes/LibrariesPane")
    panes["JobStatus"] = get_node("ColorRect/Panes/JobStatusPane")

    sub_menus["DataAnalysis"] = get_node("ColorRect/Menus/Menus/DataAnalysisSubmenu")
    sub_menus["PanDDA"] = get_node("ColorRect/Menus/Menus/PanDDASubmenu")
    sub_menus["Results"] = get_node("ColorRect/Menus/Menus/ResultsSubmenu")
    sub_menus["Project"] = get_node("ColorRect/Menus/Menus/ProjectSubmenu")

    sample_options["row1"] = [
        get_node("ColorRect/Panes/SamplesPane/row1option1"),
        get_node("ColorRect/Panes/SamplesPane/row1option2"),
    ]

    sample_options["row2"] = [
        get_node("ColorRect/Panes/SamplesPane/row2option1"),
        get_node("ColorRect/Panes/SamplesPane/row2option2"),
    ]


func _hide_all():
    for key in panes:
        panes[key].visible = false

    for key in sub_menus:
        sub_menus[key].visible = false


func select_samples():
    _hide_all()
    panes["Samples"].visible = true


func select_data_analysis():
    _hide_all()
    sub_menus["DataAnalysis"].visible = true
    panes["DataAnalysis"].visible = true


func select_pandda():
    _hide_all()
    sub_menus["PanDDA"].visible = true
    panes["PanDDA"].visible = true


func select_results():
    _hide_all()
    sub_menus["Results"].visible = true
    panes["Results"].visible = true


func select_project():
    _hide_all()
    sub_menus["Project"].visible = true
    panes["Project"].visible = true


func select_libraries():
    _hide_all()
    panes["Libraries"].visible = true


func select_job_status():
    _hide_all()
    panes["JobStatus"].visible = true


func expand_samples_row(rowName):
    print("expand ", rowName)
    for option in sample_options[rowName]:
        option.visible = true


func collapse_samples_row(rowName):
    for option in sample_options[rowName]:
        option.visible = false
