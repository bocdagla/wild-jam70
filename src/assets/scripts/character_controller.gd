class_name Character
extends Node2D

const OBJECTS_LAYER = 1

@onready var animated_sprite = $AnimatedSprite2D

@export var can_move_through: Array[int] = [0]
@export var strength: int = 1
@export var can_break: bool = false

@export var controlling: bool = false

var tile_size = 8
var inputs = {"right": Vector2i.RIGHT,
			"left": Vector2i.LEFT,
			"up": Vector2i.UP,
			"down": Vector2i.DOWN}

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	animated_sprite.play("idle")

func _unhandled_input(event):
	if controlling:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)

func get_tile(coord, layers = [1, 0]):
	var parent = get_parent() as TileMap
	for layer in layers:
		var tile = parent.get_cell_tile_data(layer, coord)
		if tile:
			return tile
	return null

func get_object(coords):
	return get_tile(coords, [OBJECTS_LAYER])

func set_object(coords, source_id, atlas_coords):
	var parent = get_parent() as TileMap
	parent.set_cell(OBJECTS_LAYER, coords, source_id, atlas_coords)

func can_move(collision_type):
	return can_move_through.has(collision_type)

func can_push(pushable_array):
	if pushable_array[0].get_custom_data("Pushable") == 0:
		return false
	
	var total_weight = 0
	for e in pushable_array:
		total_weight += e.get_custom_data("Pushable")
	if total_weight > strength:
		print("Weight too much")
		return false
	var last = pushable_array[pushable_array.size() - 1]
	var last_has_collision = last.get_custom_data("Collision") != 0
	if last_has_collision && !can_break:
		print("Can't break")
		return false
	return true

func push_objects(from, dir):
	var parent = get_parent() as TileMap
	var object_source_id = -1
	var object_atlas_coords = Vector2i.ZERO
	var i = 0
	while true:
		var cell_coords = from + inputs[dir] * i
		var tmp_object_source_id = parent.get_cell_source_id(OBJECTS_LAYER, cell_coords)
		var tmp_object_atlas_coords = parent.get_cell_atlas_coords(OBJECTS_LAYER, cell_coords)
		var object = get_object(cell_coords)
		var tile = get_tile(cell_coords, [0])
		var tile_collision = tile.get_custom_data("Collision")
		if !tile || tile_collision != 0:
			print("Broke box at", cell_coords)
			break
		
		set_object(cell_coords, object_source_id, object_atlas_coords)
		object_source_id = tmp_object_source_id
		object_atlas_coords = tmp_object_atlas_coords
		i += 1
		
		if !object || object.get_custom_data("Pushable") == 0:
			break
		

func get_pushable_objects(from, dir, objects = []):
	var cell_coords = from + inputs[dir]
	var object = get_tile(cell_coords)
	if (object):
		objects.push_back(object)
		var object_pushable = object.get_custom_data("Pushable")
		if object_pushable:
			return get_pushable_objects(cell_coords,dir,objects)
	return objects

func move(dir):
	var parent = get_parent() as TileMap
	var from_cell_coords = parent.local_to_map(position)
	var cell_coords = from_cell_coords + inputs[dir]
	var will_move = true
	
	var tile = get_tile(cell_coords)
	if tile:
		var collision = tile.get_custom_data("Collision")
		if !can_move(collision):
			will_move = false
		var object_pushable = get_pushable_objects(from_cell_coords, dir)
		if can_push(object_pushable):
			push_objects(cell_coords, dir)
	else:
		printerr("Got null tile")
	
	if will_move:
		position += Vector2(inputs[dir] * tile_size)
