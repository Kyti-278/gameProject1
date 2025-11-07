extends Node2D

@onready var peer := ENetMultiplayerPeer.new()

func _on_HostButton_pressed():
	var result = peer.create_server(1234) # порт
	if result == OK:
		multiplayer.multiplayer_peer = peer
		print("Сервер запущен на порту 1234")
		get_tree().change_scene_to_file("res://streetserver.tscn.tscn")
	else:
		print("Ошибка запуска сервера!")

func _on_JoinButton_pressed():
	var ip = $IpInput.text.strip_edges()
	if ip == "":
		ip = "192.168.0.101" # можно поставить IP сервера по умолчанию
	var result = peer.create_client(ip, 1234)
	if result == OK:
		multiplayer.multiplayer_peer = peer
		print("Подключение к серверу " + ip)
		get_tree().change_scene_to_file("res://streetserver.tscn.tscn")
	else:
		print("Ошибка подключения!")

func _on_start_pressed():
	get_tree().change_scene_to_file("res://street.tscn")   
pass # Replace th function body.
 # Replace th function body.
func _on_start2_pressed():
	get_tree().change_scene_to_file("res://street.tscn")   
pass # Replace th function body.
 # Replace th function body.

func _on_exit_pressed(): get_tree().quit()
	


func _on_setting_pressed(): get_tree().change_scene_to_file("res://setting.tscn")
 
