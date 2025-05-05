class_name RenderManager extends Node

var RESOLUTION = 10
var RADIUS = 2.0
var ISO_LEVEL = 0.0
const TRIANGULATIONS = MarchingCubesData.TRIANGULATIONS
const POINTS = MarchingCubesData.POINTS
const EDGES = MarchingCubesData.EDGES
@onready var surface_mesh = $SurfaceMesh
@onready var selected_mesh = $SelectedMesh
@onready var selection_manager : SelectionManager = get_tree().root.get_node("MainScene/SelectionManager")
@export var voxel_grid: VoxelGrid
@export var surfaces: Array[ImplicidSurface]
var negative_surfaces: Array[int] #stores indices of negative surfaces
var positive_surfaces: Array[int]
#var selection_meshes := {}
var hover_material := preload("res://materials/implicid_obj_shadered.tres")
var default_material := preload("res://materials/implicid_obj.tres")

func _ready():
	for i in surfaces.size():
		if surfaces[i].is_negative:
			negative_surfaces.append(i)
		else:
			positive_surfaces.append(i)
	
	generate_main_mesh()

func _input(event):
	if event.is_action_pressed("show_negatives"):
		for surface in surfaces:
			surface.on_show_negatives()
		surface_mesh.hide()
	if event.is_action_released("show_negatives"):
		for surface in surfaces:
			surface.on_hide_negatives()
		surface_mesh.show()

#combines all the functions into one
func _master_function(x: int, y: int, z: int):
	var result: float = surfaces[0].evaluate(x, y, z)
	#adds positive surfaces
	for i in positive_surfaces:
		result = min(result, surfaces[i].evaluate(x, y, z))
	#subtracts negative surfaces
	for i in negative_surfaces:
		result = max(result, -surfaces[i].evaluate(x, y, z))
	return result

#if no parameter is passed, generates the whole mesh, otherwise only the selection
func _generate_mesh(fn: Callable, material: Material, global_offset: Vector3) -> ArrayMesh:
	var surface_tool = SurfaceTool.new()
	
	#create scalar field
	for x in voxel_grid.resolution:
		for y in voxel_grid.resolution:
			for z in voxel_grid.resolution:
				var value = fn.call(x, y, z)
				voxel_grid.write(x, y, z, value)
	
	#march cubes
	var vertices: PackedVector3Array
	for x in voxel_grid.resolution - 1:
		for y in voxel_grid.resolution - 1 :
			for z in voxel_grid.resolution - 1:
				_march_cube(x, y, z, voxel_grid, vertices)
	
	#create mesh surface and draw
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_smooth_group(-1)
	
	for vert in vertices:
		print(vert)
		vert -= global_offset
		surface_tool.add_vertex(vert)
	
	surface_tool.generate_normals()
	surface_tool.index()
	surface_tool.set_material(material)
	return surface_tool.commit()

func generate_main_mesh():
	surface_mesh.mesh = _generate_mesh(_master_function, default_material, Vector3.ZERO)

func generate_selection_mesh(surface: ImplicidSurface) -> ArrayMesh:
	return _generate_mesh(surface.evaluate, hover_material, surface.position)

	#selection_meshes[surface] = mesh

func _march_cube(x:int, y:int, z:int, voxel_grid:VoxelGrid, vertices:PackedVector3Array):
  # Get the correct configuration
	var tri = _get_triangulation(x, y, z, voxel_grid)
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
		var position = _calculate_interpolation(pos_a, pos_b, voxel_grid)
		# Add our new vertex to our mesh's vertces array
		vertices.append(position)

func _get_triangulation(x:int, y:int, z:int, voxel_grid:VoxelGrid):
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

func _calculate_interpolation(a:Vector3, b:Vector3, voxel_grid:VoxelGrid):
	var val_a = voxel_grid.read(a.x, a.y, a.z)
	var val_b = voxel_grid.read(b.x, b.y, b.z)
	var t = (ISO_LEVEL - val_a)/(val_b-val_a)
	return a+t*(b-a)
