extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var id_screen = DisplayServer.window_get_current_screen()
	$TextureRect.size = DisplayServer.screen_get_size(id_screen)
	var img = BetaData.screen_recorder.get_screen_texture()
	$TextureRect.material.set_shader_parameter("back_screen_texture", img)

func _process(_delta):
	var img = BetaData.screen_recorder.get_screen_texture()
	$TextureRect.material.set_shader_parameter("back_screen_texture", img)

func _on_timer_timeout():
	queue_free()
