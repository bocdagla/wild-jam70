class_name Movable;
extends Node2D

const GROUND_LAYER := 0;
const OBJECTS_LAYER := 1;
const COLISION_LAYER := "Collision";
const OBJ_ID := "OBJ_ID";
@onready var parent = get_parent() as TileMap;

@export var collision_tiles_can_move_through: Array[int] = [0]; # Collisions that this can move through

@export var tile_size := 8
@export var is_pushable := true

signal blocked;

"""
Returns true if no longer in last position, false if it stayed the same
"""
func push_and_move(direction: Vector2, strength: int) -> bool:
	var can_move = false;
	var initial_cell_coords = parent.local_to_map(position)
	var next_cell_coords = initial_cell_coords  + Vector2i(direction)

	var pushable = _get_object(direction);
	if pushable:
		if strength <= 0 || !pushable.is_pushable: # doesnt have strength to push the object or object cannot be moved
			return _moved_against_collision(pushable);
		elif !pushable.push_and_move(direction, strength - 1): # if pushable wasnt pushed collide with it
			if !_moved_against_collision(pushable): # if collision results in negative result just stop moving
				return false;

	var next_tile = _get_ground(next_cell_coords);
	if !_is_valid_tile_for_moving(next_tile):
		if _moved_against_collision(null):
			blocked.emit();
			return false;

	_move(direction);
	_above_new_tile(next_tile);
	return true;

func _move(direction: Vector2):
	print("%s moved direction to %v" % [get_path(), direction])
	position += Vector2(direction * tile_size);

var debug_collision_line: Line2D;
func _get_object(direction: Vector2) -> Movable:
	var space_state = get_world_2d().direct_space_state
	var pivot = global_position;
	var destination = pivot + (direction * tile_size * global_scale);
	var query = PhysicsRayQueryParameters2D.create(pivot, destination)

	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return null;
	print("Checking objects on %v to %v" % [global_position, global_position + (direction * tile_size)])

	var movable = result.collider as Movable;
	return movable;

func _is_valid_tile_for_moving(next_tile: TileData) -> bool:
	return next_tile && collision_tiles_can_move_through.has(next_tile.get_custom_data(COLISION_LAYER));

"""
true if allows movement, false if not
"""
func _moved_against_collision(movable: Movable) -> bool:
	print("%s cannot move due to a tile blocking the way" % get_path());
	return false;

func _above_new_tile(tile_data: TileData):
	pass

func _get_ground(coords: Vector2) -> TileData:
	return parent.get_cell_tile_data(GROUND_LAYER, coords);
