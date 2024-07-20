class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene];
var mobs_per_minute:float = 60;

@onready var path_follow2d: PathFollow2D = %PathFollow2D;
var cooldown:float = 0;

func _process(delta: float):
	if (GameManager.is_game_over): return;
	#temporizador
	cooldown -= delta;
	if (cooldown > 0): return
	#intervalo
	var interval = 60.0 / mobs_per_minute;
	cooldown = interval;
	
	#checar ponto de colisão
	var point = get_point();
	var word_state = get_world_2d().direct_space_state;
	var parameters = PhysicsPointQueryParameters2D.new();
	parameters.position = point;
	parameters.collision_mask = 0b1001;
	var result:Array = word_state.intersect_point(parameters, 1);
	if (not result.is_empty()): return;
	
	#criar criatura
	var index = randi_range(0, creatures.size()-1);
	var creature_obj = creatures[index];
	var creature = creature_obj.instantiate();
	creature.global_position = get_point();
	get_parent().add_child(creature);

func get_point() -> Vector2:
	path_follow2d.progress_ratio = randf();
	return path_follow2d.global_position;
