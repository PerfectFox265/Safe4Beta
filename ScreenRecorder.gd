class_name ScreenRecorder
extends Node

# This node allow to store the back screen texture

var id_screen = 0
var _screen_texture: ImageTexture  # dont use this, call get_screen_texture() instead
var time_frame_last_screen: int = 0


func _ready():
	id_screen = DisplayServer.window_get_current_screen()
	_screen_texture = ImageTexture.create_from_image(DisplayServer.screen_get_image(id_screen))


func get_screen_texture():
	var ct = Time.get_ticks_usec()
	if time_frame_last_screen + int((1.0/BetaData.game_data.fps_screen_recorder)*(10**6)) > ct:
		return _screen_texture
	time_frame_last_screen = ct
	_screen_texture = ImageTexture.create_from_image(DisplayServer.screen_get_image(id_screen))
	return _screen_texture
