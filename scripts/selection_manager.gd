class_name SelectionManager extends Node

var selected: ImplicidSurface = null
var hover_over: ImplicidSurface = null
var ready_to_select: bool = false

func reset_hover():
	hover_over.on_unhover()
	hover_over = null

func set_hover_over(surface: ImplicidSurface):
	if hover_over == surface:
		return
	
	if hover_over == null:
		hover_over = surface
		hover_over.on_hover()
		
	hover_over.on_unhover()
	hover_over = surface
	hover_over.on_hover()

func set_selected(surface: ImplicidSurface):
	if selected == surface:
		return
	
	if selected == null:
		selected = surface
		selected.show_ui()
	
	selected.hide_ui()
	selected = surface
	selected.show_ui()
