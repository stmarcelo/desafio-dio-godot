extends AnimatedSprite2D

@export var gold_amount: int = 5;

func _ready():
	$Area2D.body_entered.connect(on_body_entered);
	
func on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		var player:Player = body;
		player.gold(gold_amount);
		queue_free();

