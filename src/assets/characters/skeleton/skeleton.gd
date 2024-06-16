extends Node2D

#@onready var ray_right = $Raycasts/RayCast2DRight
#@onready var ray_left = $Raycasts/RayCast2Left
#@onready var ray_up = $Raycasts/RayCast2DUp
#@onready var ray_down = $Raycasts/RayCast2DDown

@onready var ray = $Raycasts/RayCast2DDown


var tile_size = 8
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)

func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	ray.target_position = inputs[dir] * tile_size
	var parent = get_parent() as TileMap
	var cell_coords = parent.local_to_map(position + inputs[dir] * tile_size)
	var terrain = parent.get_cell_tile_data(0, cell_coords)
	if (terrain):
		print("Terrain: ", terrain.get_custom_data("Data"))
	var object = parent.get_cell_tile_data(1, cell_coords)
	if (object):
		print("Objects: ", object.get_custom_data("Data"))
	
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * tile_size
