extends Node

@onready var timer_label:Label = %TimerLabel;
@onready var meat_label:Label = %MeatLabel;
@onready var gold_label:Label = %GoldLabel;

func _process(delta: float):
	timer_label.text = GameManager.time_txt;
	meat_label.text = str(GameManager.meat_counter);
	gold_label.text = str(GameManager.gold_counter);

