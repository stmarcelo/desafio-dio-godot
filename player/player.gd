class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed:float = 4;
@export_category("Sword")
@export var sword_damage:int = 2;
@export_category("Magic")
@export var magic_damage: int = 5;
@export var magic_interval: float = 30;
@export var magic_scene:PackedScene;
@export_category("Life")
@export var health:int = 100;
@export var max_health:int = 100;
@export var show_death: PackedScene;

@onready var sprite:Sprite2D = $Sprite2D;
@onready var animation_player:AnimationPlayer = $AnimationPlayer;
@onready var sword_area: Area2D = $SwordArea;
@onready var hitbox_area: Area2D = $HitboxArea;
@onready var health_progressbar:ProgressBar = $HealthProgressBar;

var input:Vector2 = Vector2(0,0);
var is_running:bool = false;
var was_running:bool = false;
var is_attacking:bool = false;
var attack_cooldown:float = 0.0;
var hitbox_cooldown:float = 0.0;
var magic_cooldown:float = 0.0;

signal meat_collected(value:int);
signal gold_collected(value:int);

func _ready():
	GameManager.player = self;
	meat_collected.connect(func(value): 
		GameManager.meat_counter += 1
	);

func _process(delta: float) -> void:
	GameManager.player_position = position;
	read_input();
	#temporizador do ataque
	if (is_attacking):
		attack_cooldown -= delta;
		if (attack_cooldown < 0):
			is_attacking = false;
			is_running = false;
			animation_player.play("idle");
	#tocar animação
	if (was_running != is_running && not is_attacking):
		if(is_running):
			animation_player.play("run");
		else:
			animation_player.play("idle");
	#girar sprite
	if (not is_attacking):
		if (input.x > 0):
			sprite.flip_h = false;
		elif (input.x < 0):
			sprite.flip_h = true;
	#attack
	if (Input.is_action_just_pressed("attack")):
		attack();
		
	#processar dano
	update_hitbox_detection(delta);
	
	#processa magica
	update_magic(delta);
	
	#atualizar health bar
	health_progressbar.max_value = max_health;
	health_progressbar.value = health;

func _physics_process(delta:float) -> void:
	#modificar velocidade
	var target_velocity = input * speed * 100.0;
	if (is_attacking):
		target_velocity *= 0.25;
	velocity = lerp(velocity, target_velocity, 0.15);
	move_and_slide();

func read_input() -> void:
	#obter input vector
	input = Input.get_vector("move_left","move_right","move_up","move_down",0.15);
	#atualizar is running
	was_running = is_running;
	is_running = not input.is_zero_approx();

func attack() ->void:
	if(is_attacking):
		return;
		
	#tocar animação
	animation_player.play("attack_1");
	#marcar atando
	is_attacking = true;
	attack_cooldown = 0.6;

func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies();
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy:Enemy = body;
			var direction_to_enemy = (enemy.position - position).normalized();
			var attack_direction: Vector2;
			if (sprite.flip_h):
				attack_direction = Vector2.LEFT;
			else:
				attack_direction = Vector2.RIGHT;
			var dot_product = direction_to_enemy.dot(attack_direction);
			if (dot_product >= 0.4):
				enemy.damage(sword_damage);

func update_hitbox_detection(delta:float) -> void:
	hitbox_cooldown -= delta;
	if (hitbox_cooldown > 0): return;
	
	hitbox_cooldown = 0.5;
	var bodies = hitbox_area.get_overlapping_bodies();
	for body in bodies:
		if (body.is_in_group("enemies")):
			var enemy:Enemy = body;
			damage(enemy.hit_damage_amount);

func update_magic(delta:float) -> void:
	magic_cooldown -= delta;
	if (magic_cooldown > 0): return;
	magic_cooldown = magic_interval;
	#criar magica
	var magic = magic_scene.instantiate();
	magic.damage_amount = magic_damage;
	add_child(magic);

func damage(amount: int) -> void:
	if (health <= 0): return;
	
	health -= amount;
	#piscar node
	modulate = Color.FIREBRICK;
	var tween = create_tween();
	tween.set_ease(Tween.EASE_IN);
	tween.set_trans(Tween.TRANS_QUINT);
	tween.tween_property(self,"modulate",Color.WHITE, 0.3);
	
	#processar morte
	if (health <=0 ):
		die();

func die()->void:
	GameManager.end_game();
	
	if (show_death):
		var anim_object = show_death.instantiate();
		anim_object.position = position;
		get_parent().add_child(anim_object);
	
	queue_free();

func heal(amount: int) -> int:
	health += amount;
	if (health > max_health): health = max_health;
	return health;

func gold(value: int)->void:
	GameManager.gold_counter += value;
	gold_collected.emit(value);
