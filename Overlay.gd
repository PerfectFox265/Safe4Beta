class_name Overlay
extends Node2D

const TIME_BETWEEN_DETECTION = 0.5
var boxes = []
var id_screen
var screen_size: Vector2i
var screen_area: int
@onready var overlay_hud = $OverlayHUD
@onready var warning_message = $WarningMessage
@onready var tcp_listner = $TCPListner
@onready var beta_voices = $BetaVoices

func _ready():
	var r : Window = get_tree().get_root()
	r.set_transparent_background(true)
	make_overlay_fullscreen()
	overlay_hud.visible = BetaData.game_data.game_mode
	warning_message.position = Vector2(screen_size.x/2.0, screen_size.y/2.0)
	r.exclude_from_capture = true


func make_overlay_fullscreen():
	# using get_tree().get_root().set_mode(Window.MODE_FULLSCREEN) create a
	# weird border all around the screen
	var window_id = get_tree().get_root().get_window_id()
	id_screen = DisplayServer.window_get_current_screen(window_id)
	screen_size = DisplayServer.screen_get_size(id_screen) - Vector2i(1, 1)
	screen_area = screen_size.x * screen_size.y
	await get_tree().process_frame  # this hopefully reduce the lag at first start
	get_tree().get_root().set_size(screen_size)
	var screen_position = DisplayServer.screen_get_position(id_screen)
	get_tree().get_root().set_position(screen_position)


func draw_censor(detections: String):
	# delete old boxes
	for b in boxes:
		remove_child(b)
	boxes = []
	# add new boxes
	var detections_array = JSON.parse_string(detections)
	
	if BetaData.is_warning:
		BetaData.update_warning(len(detections_array) == 0)
	for d in detections_array:
		if not BetaData.game_data.game_mode:
			draw_custom_detection(d)
			continue
		var censor_scn = BetaData.get_censor_scn_for_detection(d)
		if censor_scn != null:
			add_censor_box(censor_scn, d)


func add_censor_box(box_scn, detection):
	var c_b = box_scn.instantiate()
	c_b.class_detect = detection["class"]
	c_b.score_detect = detection["score"]
	c_b.box_detect = detection["box"]
	add_child(c_b)
	boxes.append(c_b)

#func draw_custom_detection(detection):
	#var custom_censor: Dictionary = BetaData.get_custom_censor_scn_for_detection(detection)
	#var censor_scn = custom_censor.get("box_scn")
	#if censor_scn == null:
		#return
	#var sx = custom_censor.get("sx", 1)
	#var sy = custom_censor.get("sy", 1)
	#BetaData.rescale_detection(detection, sx, sy)
	#add_censor_box(censor_scn, detection)

func draw_custom_detection(detection):
	var censor_scn_id = BetaData.game_data.custom_censors
	var censor_scn = BetaData.box_scn_types[censor_scn_id]
	var type_detect = BetaData.censor_type_of_part(detection["class"], detection["score"])
	if type_detect == -1:
		return
	var type_mask = 1 << type_detect
	if type_mask & BetaData.game_data.custom_censor_mask:
		add_censor_box(censor_scn, detection)
