extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D

var health = 100
var equipped_weapon: Node2D = null

func _physics_process(delta):
	# Простое толкание ящиков (вставь в _physics_process после move_and_slide())

	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta

	# Прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Горизонтальное движение
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():  # Исправлено: проверка на земле, а не velocity.y == 0
			anim.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			anim.play("Idie")

	# Поворот спрайта
	if direction == -1:
		anim.flip_h = true
	elif direction == 1:
		anim.flip_h = false
		# Толкание ящиков
	if is_on_floor() and direction != 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision and collision.get_collider().is_in_group("box"):
				var box = collision.get_collider()
				if box is RigidBody2D:
					box.apply_impulse(Vector2.ZERO, Vector2(direction, 0) * 250)

	# Смерть
	if health <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")

	move_and_slide()

	# --- поворот оружия за мышкой ---
	if equipped_weapon:
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position).normalized()
		equipped_weapon.rotation = dir.angle()
func _process(delta):
	if str(multiplayer.get_unique_id()) != name:
		return # управляем только своим персонажем

	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	velocity = input * SPEED
	move_and_slide()
	rpc("update_pos", global_position)
	
@rpc("any_peer", "unreliable")
func update_pos(new_pos: Vector2):
	if str(multiplayer.get_unique_id()) != name:
		global_position = new_pos
