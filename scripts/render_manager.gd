extends Node

var RESOLUTION = 10
var offset = RESOLUTION / 2
var RADIUS = 2.0
var ISO_LEVEL = 0.0
var grid_pos
var relative_pos
const TRIANGULATIONS = MarchingCubesData.TRIANGULATIONS
const POINTS = MarchingCubesData.POINTS
const EDGES = MarchingCubesData.EDGES
@onready var surface_mesh = $SurfaceMesh
@onready var selected_mesh = $SelectedMesh
@onready var selection_manager = get_tree().root.get_node("MainScene/SelectionManager")
@export var MATERIAL: Material
@export var FLAT_SHADED := true
@export var voxel_grid: VoxelGrid
@export var surfaces: Array[ImplicidSurface]
var hover_material := preload("res://materials/implicid_obj_shadered.tres")
var default_material := preload("res://materials/implicid_obj.tres")

func _ready():
	generate_mesh()
	
	for surface in surfaces:
		surface.selection_mouse_enter.connect(_on_selection_mouse_enter.bind(surface))
		surface.selection_mouse_exit.connect(_on_selection_mouse_exit.bind(surface))

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and selection_manager.hover_over:
		selection_manager.set_selected(selection_manager.hover_over)

#combines all the functions into one
func master_function(x: int, y: int, z: int):
	var result: float = surfaces[0].evaluate(x, y, z)
	#adds positive surfaces
	for i in surfaces.size():
		#has to be min/max later + do smth with r
		print(surfaces[i])
		result = min(result, surfaces[i].evaluate(x, y, z))
	return result
	#subtracts negative surfaces

#if no parameter is passed, generates the whole mesh, otherwise only the selection
func generate_mesh(selected_surface : ImplicidSurface = null):
	var mesh: MeshInstance3D
	var surface_tool = SurfaceTool.new()
	var material = Material
	
	#create scalar field
	if selected_surface == null:
		print("called")
		mesh = surface_mesh
		material = default_material
		for x in voxel_grid.resolution:
			for y in voxel_grid.resolution:
				for z in voxel_grid.resolution:
					var value = master_function(x, y, z)
					voxel_grid.write(x, y, z, value)
	else:
		mesh = selected_mesh
		material = hover_material
		for x in voxel_grid.resolution:
			for y in voxel_grid.resolution:
				for z in voxel_grid.resolution:
					var value = selected_surface.evaluate(x, y, z)
					voxel_grid.write(x, y, z, value)
	
	#march cubes
	var vertices: PackedVector3Array
	for x in voxel_grid.resolution - 1:
		for y in voxel_grid.resolution - 1 :
			for z in voxel_grid.resolution - 1:
				march_cube(x, y, z, voxel_grid, vertices)
	
	#create mesh surface and draw
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	if FLAT_SHADED:
		surface_tool.set_smooth_group(-1)
	
	for vert in vertices:
		surface_tool.add_vertex(vert)
	
	surface_tool.generate_normals()
	surface_tool.index()
	surface_tool.set_material(material)
	mesh.mesh = surface_tool.commit()

func march_cube(x:int, y:int, z:int, voxel_grid:VoxelGrid, vertices:PackedVector3Array):
  # Get the correct configuration
	var tri = get_triangulation(x, y, z, voxel_grid)
	for edge_index in tri:
		if edge_index < 0: break
		# Get edge
		var point_indices = EDGES[edge_index]
		# Get 2 points connecting this edge
		var p0 = POINTS[point_indices.x]
		var p1 = POINTS[point_indices.y]
		# Global position of these 2 points
		var pos_a = Vector3(x+p0.x, y+p0.y, z+p0.z)
		var pos_b = Vector3(x+p1.x, y+p1.y, z+p1.z)
		# Interpolate between these 2 points to get our mesh's vertex position
		var position = calculate_interpolation(pos_a, pos_b, voxel_grid)
		# Add our new vertex to our mesh's vertces array
		vertices.append(position)

func get_triangulation(x:int, y:int, z:int, voxel_grid:VoxelGrid):
	var idx = 0b00000000
	idx |= int(voxel_grid.read(x, y, z) < ISO_LEVEL)<<0
	idx |= int(voxel_grid.read(x, y, z+1) < ISO_LEVEL)<<1
	idx |= int(voxel_grid.read(x+1, y, z+1) < ISO_LEVEL)<<2
	idx |= int(voxel_grid.read(x+1, y, z) < ISO_LEVEL)<<3
	idx |= int(voxel_grid.read(x, y+1, z) < ISO_LEVEL)<<4
	idx |= int(voxel_grid.read(x, y+1, z+1) < ISO_LEVEL)<<5
	idx |= int(voxel_grid.read(x+1, y+1, z+1) < ISO_LEVEL)<<6
	idx |= int(voxel_grid.read(x+1, y+1, z) < ISO_LEVEL)<<7
	return TRIANGULATIONS[idx]

func calculate_interpolation(a:Vector3, b:Vector3, voxel_grid:VoxelGrid):
	var val_a = voxel_grid.read(a.x, a.y, a.z)
	var val_b = voxel_grid.read(b.x, b.y, b.z)
	var t = (ISO_LEVEL - val_a)/(val_b-val_a)
	return a+t*(b-a)

func _on_selection_mouse_enter(surface: ImplicidSurface):
	selection_manager.hover_over = surface
	generate_mesh(surface)

func _on_selection_mouse_exit(surface: ImplicidSurface):
	selected_mesh.mesh = null
	selection_manager.hover_over = null
