@tool
extends MeshInstance3D

var RESOLUTION = 10
var offset = RESOLUTION / 2
var RADIUS = 2.0
var ISO_LEVEL = 0.0
var pos
var grid_pos
var relative_pos
var voxel_grid
const TRIANGULATIONS = MarchingCubesData.TRIANGULATIONS
const POINTS = MarchingCubesData.POINTS
const EDGES = MarchingCubesData.EDGES
@export var MATERIAL: Material
@export var FLAT_SHADED: bool
@onready var parent = $".."
@onready var collision_shape = $"../Area3D/CollisionShape3D"




func _ready():
	pos = parent.position
	voxel_grid = parent.voxel_grid
	grid_pos = voxel_grid.position
	relative_pos = grid_pos - pos
	generate()

func sphere(x: int, y: int, z: int, r: float):
	return x*x + y*y + z*z - r*r;

func heart(x: int, y: int, z: int, r: float):
	return pow((x*x + y*y + z*z - 1),3) - (1/5*x*x + y*y) * pow(z,3)

func elliptic(x: int, y: int, z: int):
	return x*x - y*y - z*z + 1

func generate():
	print("iso level: ", ISO_LEVEL)
	print("radius: ", RADIUS)
	#var voxel_grid = VoxelGrid.new(RESOLUTION)
	#var relative_pos = pos - grid_pos - Vector3(offset, offset, offset)
	
	print("relative position: ", relative_pos)
	#create scalar field
	for x in voxel_grid.resolution:
		for y in voxel_grid.resolution:
			for z in voxel_grid.resolution:
				var sphere1 = sphere(relative_pos.x + x, relative_pos.y + y, relative_pos.z + z, RADIUS)
				#var sphere2 = -sphere(x - offset - 2, y - offset - 2, z - offset - 1, RADIUS / 1.5)
				voxel_grid.write(x, y, z, sphere1)
	
	#march cubes
	var vertices: PackedVector3Array
	for x in voxel_grid.resolution - 1:
		for y in voxel_grid.resolution - 1 :
			for z in voxel_grid.resolution - 1:
				march_cube(x, y, z, voxel_grid, vertices)
	
	#create mesh surface and draw
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	
	if FLAT_SHADED:
		surface_tool.set_smooth_group(-1)
	
	for vert in vertices:
		surface_tool.add_vertex(vert)
	
	surface_tool.generate_normals()
	surface_tool.index()
	surface_tool.set_material(MATERIAL)
	mesh = surface_tool.commit()

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
		#var position = calculate_interpolation(pos_a, pos_b, voxel_grid) - Vector3(offset, offset, offset)
		var position = calculate_interpolation(pos_a, pos_b, voxel_grid) + relative_pos
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


func _on_slider_iso_value_changed(value):
	ISO_LEVEL = value
	generate()


func _on_slider_radius_value_changed(value):
	RADIUS = value
	collision_shape.update_scale(value * 2)
	print(value)
	generate()


func _on_slider_res_value_changed(value):
	RESOLUTION = value
	generate()
