class_name IngamePlayerInputHandler;
extends Node

@export var available_chars: Array[Character];
@export var current_character_index: int = 0;
@export var currchar_label = Label;

var inputs = {"right": Vector2i.RIGHT,
			"left": Vector2i.LEFT,
			"up": Vector2i.UP,
			"down": Vector2i.DOWN}

func _ready() -> void:
	call_deferred("activate_char", available_chars[current_character_index]);

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("shoulder_r"):
		next_char();
	elif event.is_action_pressed("shoulder_l"):
		prev_char();

	for dir in inputs.keys():
		if _handle_movement(event, dir):
			break;

func _handle_movement(event: InputEvent, dir: String) -> bool:
	if event.is_action_pressed(dir):
		available_chars[current_character_index].move(inputs[dir]);
		return true;
	return false;

func next_char():
	var previous_character_index = current_character_index;
	current_character_index += 1;
	if current_character_index >= available_chars.size():
		current_character_index = 0;
	activate_char(available_chars[current_character_index], available_chars[previous_character_index]);

func prev_char():
	var previous_character_index = current_character_index;
	current_character_index -= 1;
	if current_character_index < 0:
		current_character_index = available_chars.size() - 1;
	activate_char(available_chars[current_character_index], available_chars[previous_character_index]);

func activate_char(next: Character, prev: Character = null):
	if prev:
		prev.activate(false);
	next.activate(true);
	if currchar_label:
		currchar_label.text = next.name;
