extends Button


func _on_pressed():
    var control = get_node("/root/Control")
    var rowName = get_parent().name
    var expand = self.text == "+"

    if expand:
        self.text = "-"
        control.expand_samples_row(rowName)
    else:
        self.text = "+"
        control.collapse_samples_row(rowName)
