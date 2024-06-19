class_name Character
extends Movable

@onready var animated_sprite = $AnimatedSprite2D
@onready var ingame_player_input_handler: IngamePlayerInputHandler = %IngamePlayerInputHandler

@export var strength: int = 0
@export var controlling: bool = false

signal activated(is_active: bool);

func _ready():
	animated_sprite.play("idle")

func activate(active: bool):
	controlling = active;
	activated.emit(active);

func move(direction: Vector2):
	push_and_move(direction, strength);
