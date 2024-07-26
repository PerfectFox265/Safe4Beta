class_name ScreenRecorder
extends Node

# This node allow to store the back screen texture

var id_screen = 0
var _screen_texture: ImageTexture  # dont use this, call get_screen_texture() instead
var id_frame_last_screen = -1

const additional_skipped_frames = 1 # skipped x frames between records

func _ready():
	id_screen = DisplayServer.window_get_current_screen()
	_screen_texture = ImageTexture.create_from_image(DisplayServer.screen_get_image(id_screen))


func get_screen_texture():
	var fc = Engine.get_process_frames()
	if id_frame_last_screen + additional_skipped_frames > fc:
		return _screen_texture
	id_frame_last_screen = fc
	_screen_texture = ImageTexture.create_from_image(DisplayServer.screen_get_image(id_screen))
	return _screen_texture
