class_name SelectionManager extends Node

var is_selecting: bool = false
var selected: ImplicidSurface = null
var hover_over: ImplicidSurface = null
var ready_to_select: bool = false
var disabled = true #to prevent alt + shift

func _input(event):
	if event.is_action_pressed("show_negatives"):
		disabled = true
		return
	if event.is_action_released("show_negatives"):
		disabled = false
	if disabled:
		return
	if event.is_action_pressed("select_surface"):
		is_selecting = true
		if hover_over:
			set_hover_over(hover_over)
	if event.is_action_released("select_surface"):
		is_selecting = false
		if hover_over:
			hover_over.on_unhover()
	if is_selecting and hover_over and event.is_action_pressed("select"):
		set_selected(hover_over)

func reset_hover():
	if hover_over != null:
		hover_over.on_unhover()
		hover_over = null

func set_hover_over(surface: ImplicidSurface):
	if hover_over != surface:
		hover_over = surface
	if is_selecting:
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
