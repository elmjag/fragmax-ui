extends Control

var panes = {}
var sub_menus = {}

func _ready():
	panes["Samples"] = get_node("ColorRect/HBoxContainer/SamplesPane")
	panes["DataAnalysis"] = get_node("ColorRect/HBoxContainer/DataAnalysisPane")
	panes["Project"] = get_node("ColorRect/HBoxContainer/ProjectPane")
	panes["PanDDA"] = get_node("ColorRect/HBoxContainer/PanDDAPane")
	panes["Results"] = get_node("ColorRect/HBoxContainer/ResultsPane")
	panes["Libraries"] = get_node("ColorRect/HBoxContainer/LibrariesPane")
	panes["JobStatus"] = get_node("ColorRect/HBoxContainer/JobStatusPane")
	
	sub_menus["DataAnalysis"] = get_node("ColorRect/HBoxContainer/Menus/DataAnalysisSubmenu")
	sub_menus["PanDDA"] = get_node("ColorRect/HBoxContainer/Menus/PanDDASubmenu")
	sub_menus["Results"] = get_node("ColorRect/HBoxContainer/Menus/ResultsSubmenu")
	sub_menus["Project"] = get_node("ColorRect/HBoxContainer/Menus/ProjectSubmenu")


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
