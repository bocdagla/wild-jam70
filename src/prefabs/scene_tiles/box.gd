class_name Box;
extends Movable;

func _moved_against_collision(movable: Movable) -> bool:
	if movable is Box or movable is Character:
		print("%s box is blocked by another thing %s" % [name, movable.name])
		return false;
	print("%s box got destroyed" % name)
	queue_free();
	return true;
