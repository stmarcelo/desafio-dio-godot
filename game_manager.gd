extends Node

signal game_over;

var player:Player;
var player_position: Vector2;

var is_game_over: bool = false;

var time_elapsed: float = 0;
var time_txt:String;
var meat_counter:int = 0;
var gold_counter:int = 0;
var monster_defeated_counter:int;

func _process(delta: float):
	time_elapsed += delta;
	var seconds_elapsed:int = floori(time_elapsed);
	var seconds:int = seconds_elapsed % 60;
	var minutes:int = seconds_elapsed / 60;
	time_txt = "%02d:%02d" % [minutes,seconds];

func end_game():
	if (is_game_over): return;
	
	is_game_over = true;
	game_over.emit();

func reset():
	player = null;
	player_position = Vector2.ZERO;
	is_game_over = false;
	time_elapsed = 0.0;
	meat_counter = 0;
	monster_defeated_counter = 0;
	for conn in game_over.get_connections():
		game_over.disconnect(conn.callable);
