extends Node

var selected: ImplicidSurface = null

func set_selected(surface):
	if selected == surface:
		return
	
	if selected == null:
		selected = surface
		selected.show_ui()
	
	selected.hide_ui()
	selected = surface
	selected.show_ui()
