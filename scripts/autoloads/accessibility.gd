extends Node2D


func _ready():
	var user_screen_size = DisplayServer.screen_get_size()
	DisplayServer.window_set_size(user_screen_size / 2)
