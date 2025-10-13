extends CharacterBody2D

@export var speed: float = 150.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var chase_distance: float = 200.0
@export var jump_force: float = 400.0
@export var attack_damage: int = 4
@export var attack_cooldown: float = 1.0

var player: Node2D = null
var can_attack: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var attack_timer: Timer

func _ready():
	# Поиск игрока по сцене (структура: Player2/Player)
	var street = get_tree().current_scene
	if street.has_node("Player2/Player"):
		player = street.get_node("Player2/Player")
	else:
		print_debug("Player node not found!")

	# Таймер для контроля атаки
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_cooldown
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if player == null:
		velocity.x = 0
		_play_animation("Idle")
		move_and_slide()
		return

	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var direction_to_player = player.global_position - global_position
	var distance_to_player = direction_to_player.length()
	var dir_x = sign(direction_to_player.x)

	# Следим и двигаемся к игроку в пределах chase_distance
	if distance_to_player > chase_distance:
		velocity.x = 0
		_play_animation("Idle")
	else:
		velocity.x = dir_x * speed
		animated_sprite.flip_h = dir_x < 0

		# Прыгаем, если игрок выше
		if is_on_floor() and (player.global_position.y + 10) < global_position.y:
			velocity.y = -jump_force
			_play_animation("jump")
		elif abs(velocity.x) > 1:
			_play_animation("run")
		else:
			_play_animation("Idle")

		# Атака
		if distance_to_player < 30 and can_attack:
			_attack_player()

	move_and_slide()

func _play_animation(name: String):
	if animated_sprite.animation != name:
		animated_sprite.play(name)

func _attack_player():
	if player == null:
		return

	# Урон через метод или health
	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
	elif "health" in player:
		player.health -= attack_damage

	can_attack = false
	attack_timer.start()

func _on_attack_timer_timeout():
	can_attack = true
