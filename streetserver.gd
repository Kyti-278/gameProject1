extends Node2D

@onready var PlayerScene = preload("res://player.tscn")

func _ready():
	if multiplayer.is_server():
		spawn_player(multiplayer.get_unique_id(), Vector2(100, 200))
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id):
	print("Игрок подключился: ", id)
	spawn_player(id, Vector2(300, 200))

@rpc("any_peer")
func spawn_player(id: int, pos: Vector2):
	var player = PlayerScene.instantiate()
	player.name = str(id)
	player.position = pos
	add_child(player)
