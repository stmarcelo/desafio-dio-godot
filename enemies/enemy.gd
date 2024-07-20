class_name Enemy
extends Node2D

@export_category("Life")
@export var health:int = 10;
@export var hit_damage_amount:int = 2;
@export var show_death: PackedScene;

@export_category("Drops")
@export var drop_chance: float = 0.1;
@export var drop_items: Array[PackedScene];
@export var drop_chances: Array[float];

var damage_show_pre:PackedScene;
var marker2d:Marker2D;
func _ready():
	damage_show_pre = preload("res://enemies/damage_show.tscn");
	marker2d = $Marker2D;

func damage(amount: int) -> void:
	health -= amount;
	#piscar node
	modulate = Color.FIREBRICK;
	var tween = create_tween();
	tween.set_ease(Tween.EASE_IN);
	tween.set_trans(Tween.TRANS_QUINT);
	tween.tween_property(self,"modulate",Color.WHITE, 0.3);
	
	#mostrar dano
	var damage_show = damage_show_pre.instantiate();
	damage_show.value = amount;
	if (marker2d):
		damage_show.global_position = marker2d.global_position;
	else:
		damage_show.global_position = global_position;
	get_parent().add_child(damage_show);
	
	#processar morte
	if (health <=0 ):
		die();

func die()->void:
	if (show_death):
		var anim_object = show_death.instantiate();
		anim_object.position = position;
		get_parent().add_child(anim_object);
	
	#drop
	if (randf() <= drop_chance):
		drop_item();
	
	GameManager.monster_defeated_counter += 1;
	
	#garbage collect
	queue_free();

func drop_item() -> void:
	var item_object = get_random_item().instantiate();
	item_object.position = position;
	get_parent().add_child(item_object);
	

func get_random_item() -> PackedScene:
	if (drop_items.size() == 1): return drop_items[0];
	
	var max_chance: float = 0;
	for chance in drop_chances:
		max_chance += chance;
		
	var random_value = randf() * max_chance;
	#girar roleta
	var needle:float = 0;
	for i in drop_items.size():
		var drop_item = drop_items[i];
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1;
		needle += drop_chance;
		if (random_value <= needle):
			return drop_item;
			
	return drop_items[0];
