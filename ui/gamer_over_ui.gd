class_name GameOverUI
extends CanvasLayer

@onready var time_label = %TimeLabel;
@onready var monster_label = %MonstersLabel;

@export var restart_delay: float = 5;
var restart_cooldown:float;


func _ready():
	time_label.text = GameManager.time_txt;
	monster_label.text = str(GameManager.monster_defeated_counter);
	restart_cooldown = restart_delay;

func _process(delta):
	restart_cooldown -= delta;
	if (restart_cooldown <= 0.0):
		restart_game();

func restart_game():
	GameManager.reset();
	get_tree().reload_current_scene();
