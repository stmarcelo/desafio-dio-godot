extends Node2D

var value:int = 0;

func _ready():
	%DamageEnemyShowLabel.text = str(value);
