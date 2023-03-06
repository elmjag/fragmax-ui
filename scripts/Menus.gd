extends VBoxContainer


const utils = preload("res://scripts/utils.gd")
onready var model = get_node("/root/Control/model")

var submenu = null
var pane = null


func _ready():
    utils.model_connect(self, "_model_updated")

    _connect_menu(get_node("Samples"))
    _connect_menu(get_node("DataAnalysis"), "DataAnalysisProcess")
    _connect_menu(find_node("DataAnalysisProcess"), "DataAnalysisProcess")
    _connect_menu(find_node("DataAnalysisRefine"), "DataAnalysisRefine")
    _connect_menu(find_node("DataAnalysisFitLigands"), "DataAnalysisFitLigands")
    _connect_menu(find_node("DataAnalysisPandda"), "DataAnalysisPandda")
    _connect_menu(get_node("PanDDA"), "PanddaAnalyse")
    _connect_menu(find_node("PanddaAnalyse"))
    _connect_menu(find_node("PanddaInspect"))
    _connect_menu(get_node("Project"), "ProjectPDBs")
    _connect_menu(find_node("ProjectPDBs"))
    _connect_menu(find_node("ProjectDetails"))
    _connect_menu(find_node("ProjectSettings"))
    _connect_menu(get_node("Libraries"))
    _connect_menu(get_node("JobsStatus"))


func _connect_menu(menu_button, pane_name = null):
    if pane_name == null:
        pane_name = menu_button.name

    menu_button.connect("pressed", self, "_on_menu_pressed", [pane_name])



func _on_menu_pressed(pane_name):
    model.do(Model.Actions.SELECT_PANE, pane_name)


func _model_updated(state):
    var new_pane = state.ui.current_pane

    if submenu != null:
        submenu.visible = false
        submenu = null

    match new_pane:
        "DataAnalysisProcess", \
        "DataAnalysisRefine", \
        "DataAnalysisFitLigands", \
        "DataAnalysisPandda":
            submenu = get_node("DataAnalysisSubmenu")
        "PanddaAnalyse", \
        "PanddaInspect":
            submenu = get_node("PanDDASubmenu")
        "ProjectPDBs", \
        "ProjectDetails", \
        "ProjectSettings":
            submenu = get_node("ProjectSubmenu")

    if submenu != null:
        submenu.visible = true
