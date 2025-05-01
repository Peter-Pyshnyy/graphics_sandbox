extends MeshInstance3D

var resolution: int
var res_half: int
var corner_pos: Vector3
var res_up: Vector3
var res_right: Vector3
var res_forward: Vector3
@export var MATERIAL: Material

func gen_grid_borders_mesh():
	print("GENERATING BORDER MESH")
	resolution = $"..".resolution
	res_half = resolution / 2
	corner_pos = position + Vector3(-res_half, res_half, -res_half)
	res_up = Vector3(resolution, 0, 0)
	res_right = Vector3(0, resolution, 0)
	res_forward = Vector3(0, 0, resolution)
	
	var new_mesh = ArrayMesh.new()
	var vertices := PackedVector3Array([
		#back side
		corner_pos,
		corner_pos + res_right,
		corner_pos - res_up,
		corner_pos + res_right - res_up,
		
		#front side
		corner_pos + res_forward,
		corner_pos + res_right + res_forward,
		corner_pos - res_up + res_forward,
		corner_pos + res_right - res_up + res_forward,])
	
	var indices := PackedInt32Array([
		# back 
		0, 2, 1,
		1, 2, 3,
		# right
		1, 3, 5,
		5, 3, 7,
		# front
		5, 7, 4,
		4, 7, 6,
		# left
		4, 6, 0,
		0, 6, 2,
		# top
		4, 0, 5,
		5, 0, 1,
		# bottom
		2, 6, 3,
		3, 6, 7])
	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vertices
	arr[Mesh.ARRAY_INDEX] = indices
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	if MATERIAL:
		new_mesh.surface_set_material(0, MATERIAL)
	mesh = new_mesh
