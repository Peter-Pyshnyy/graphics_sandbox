extends Control
var iso: float = 0.0

signal iso_slider_changed()

func 

func _on_h_slider_value_changed(value):
	iso_slider_changed.emit()
