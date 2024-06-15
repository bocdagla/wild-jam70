extends Node2D

@onready var ray_right = $Raycasts/RayCast2DRight
@onready var ray_left = $Raycasts/RayCast2Left
@onready var ray_up = $Raycasts/RayCast2DUp
@onready var ray_down = $Raycasts/RayCast2DDown

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
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * tile_size
