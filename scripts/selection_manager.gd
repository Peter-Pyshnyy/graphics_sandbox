extends Node

var selected: ImplicidSurface = null
var hover_over: ImplicidSurface = null
var ready_to_select: bool = false

func set_selected(surface):
	if selected == surface:
		return
	
	if selected == null:
		selected = surface
		selected.show_ui()
	
	selected.hide_ui()
	selected = surface
	selected.show_ui()
