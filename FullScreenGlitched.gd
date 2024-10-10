extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect.size = BetaData.overlay.screen_size
	var img = BetaData.screen_recorder.get_screen_texture()
	$TextureRect.material.set_shader_parameter("back_screen_texture", img)

func _process(_delta):
	var img = BetaData.screen_recorder.get_screen_texture()
	$TextureRect.material.set_shader_parameter("back_screen_texture", img)

func _on_timer_timeout():
	queue_free()
