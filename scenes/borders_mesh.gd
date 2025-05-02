extends MeshInstance3D

var resolution: int
var res_half: int
var res_up: Vector3
var res_right: Vector3
var res_forward: Vector3
@export var MATERIAL: Material

func get_corner_pos():
	resolution = $"..".resolution
	res_half = resolution / 2
	return position + Vector3(-res_half, res_half, -res_half)

func gen_grid_borders_mesh():
	var corner_pos = get_corner_pos()
	# -1 because MC loops 0 to res - 1
	res_right = Vector3(resolution - 1, 0, 0)
	res_up = Vector3(0, resolution - 1, 0)
	res_forward = Vector3(0, 0, resolution - 1)
	
	var new_mesh = ArrayMesh.new()
	
	var vertices := PackedVector3Array([
		#back side
		Vector3(0,0,0),
		res_right,
		res_up,
		res_right + res_up,
		
		#front side
		res_forward,
		res_right + res_forward,
		res_up + res_forward,
		res_right + res_up + res_forward,])
	
	
	var indices := PackedInt32Array([
		#back
		0, 1, 2,
		1, 3, 2,
		#right
		1, 5, 3,
		5, 7, 3,
		#front
		5, 4, 7,
		4, 6, 7,
		#left
		4, 0, 6,
		0, 2, 6,
		#top
		4, 5, 0,
		5, 1, 0,
		#bottom
		2, 3, 6,
		3, 7, 6
	])
	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vertices
	arr[Mesh.ARRAY_INDEX] = indices
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, arr)
	if MATERIAL:
		new_mesh.surface_set_material(0, MATERIAL)
	mesh = new_mesh

func gen_grid_point_mesh():
	var corner_pos = get_corner_pos()
	var new_mesh = ArrayMesh.new()
	var vertices := PackedVector3Array()
	
	for x in resolution:
		for y in resolution:
			for z in resolution:
				vertices.append(Vector3(x, y, z))
	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vertices
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arr)
	if MATERIAL:
		new_mesh.surface_set_material(0, MATERIAL)
	mesh = new_mesh

func remove_grid_mesh():
	mesh = ArrayMesh.new()
