extends Area2D

@export var initial_speed: float = 500.0
@export var lifetime: float = 0.5 # Уменьшено для уменьшения расстояния полёта
@export var damage: int = 10
@export var bullet_gravity: float = 500.0  # ← Изменили имя переменной!

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO
var initial_position: Vector2

func _ready():
	velocity = direction * initial_speed
	initial_position = position
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime
	add_child(timer)
	timer.timeout.connect(func(): queue_free())
	timer.start()

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Применяем гравитацию (используем bullet_gravity вместо gravity)
	velocity.y += bullet_gravity * delta
	position += velocity * delta
	
	# Поворачиваем спрайт в сторону движения
	if velocity.length() > 0:
		$Sprite2D.rotation = velocity.angle()
	
	# Проверяем, не улетела ли пуля слишком далеко
	if position.distance_to(initial_position) > 300:  # Ограничиваем расстояние
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player") or area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		elif "health" in area:
			area.health -= damage
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		elif "health" in body:
			body.health -= damage
		queue_free()
