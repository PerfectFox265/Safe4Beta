extends Node
# Game data manager
const config_path = "./config.json"
var overlay: Overlay
var screen_recorder: ScreenRecorder
var menu: GameMenu
var time_last_detection = 0
var sec_between_detection = 0.5
var current_screen_score_diff = 0.0
var is_warning = false
var duration_without_detections = 0.0
var is_eco_active = false
const score_next_lvl = 2000

const full_screen_glitched_scn = preload("res://GameMode/full_screen_glitched.tscn")
const TEXT_CENSOR_BOX = preload("res://BoxExamples/text_censor_box.tscn")
const SUBLIM_MESSAGE_BOX = preload("res://BoxExamples/sublim_message_box.tscn")
const GLITCHED_BOX = preload("res://BoxExamples/glitched_box.tscn")
const CUSTOM_TEXTURE_CENSOR_BOX = preload("res://BoxExamples/custom_texture_censor_box.tscn")
const BASE_CENSOR_BOX = preload("res://BoxExamples/base_censor_box.tscn")
var box_scn_types = [BASE_CENSOR_BOX, GLITCHED_BOX, SUBLIM_MESSAGE_BOX,
	TEXT_CENSOR_BOX, CUSTOM_TEXTURE_CENSOR_BOX,
]
var custom_texture: ImageTexture = null

const FULL_SCREEN_TEXT_CREATOR = preload("res://BoxExamples/full_screen_text_creator.tscn")

const _labels = [
	"FEMALE_GENITALIA_COVERED",
	"FEMALE_GENITALIA_EXPOSED",
	"ANUS_COVERED",
	"ANUS_EXPOSED",
	"BUTTOCKS_COVERED",
	"BUTTOCKS_EXPOSED",
	"FEMALE_BREAST_COVERED",
	"FEMALE_BREAST_EXPOSED",
	"FEET_COVERED",
	"FEET_EXPOSED",
	"BELLY_COVERED", # not used
	"BELLY_EXPOSED",
	"ARMPITS_COVERED", # not used
	"ARMPITS_EXPOSED",
	"FACE_FEMALE",
	
	"FACE_MALE",
	"MALE_BREAST_EXPOSED",
	"MALE_GENITALIA_EXPOSED",
]

# lua style dict to store config in json
# can access with game_data.score or game_data["score"]
var game_data := {
	score = 1,
	audio = true,
	lvl = 0,
	game_mode = true,
	hud_visible = true,
	hud_x = 0,
	hud_y = 0,
	hud_scale = 1,
	fs_text_censor = "Beta Keep Out ",
	cd_detections = 0.1,
	eco_detections = false,
	cd_comments = 20,
	custom_censors = 0,
	custom_censor_mask = int(1),
	custom_texture = "./fox.png",
	fps_screen_recorder = 30,
	#never change old data name to avoid breaking old saves
}


func _ready():
	overlay = get_node("/root/Overlay")
	screen_recorder = get_node("/root/Overlay/ScreenRecorder")
	var is_existing_save = load_config_json()
	apply_new_config(is_existing_save)


func _exit_tree():
	save_config_json()

func load_config_json():
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		var saved_data: Dictionary = JSON.parse_string(file.get_as_text())
		for key in game_data.keys():
			var saved_value = saved_data.get(key)
			if saved_value != null: game_data[key] = saved_value
		file.close()
		return true
	print("No config file. Creating a new save...")
	return false

func apply_new_config(is_existing_save):
	# most of nodes are not ready at this time
	# lots of config is done in menu::apply_menu_config()
	await get_tree().process_frame
	new_fullscreen_text_texture(game_data.fs_text_censor)
	overlay.tcp_listner.restart_detector(game_data.cd_detections)
	if game_data.game_mode:
		if not is_existing_save:
			overlay.beta_voices.get_node("intro").play()
			await get_tree().create_timer(3.5).timeout
		make_screen_glitched()

func save_config_json():
	# this will erase the previous config
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(game_data))
	file.close()
	

func censor_type_of_part(body_part : String, score : float):
	var bp = body_part
	var is_low_face_male = (bp=="FACE_MALE" and score < 0.4)  # face male is very imprecise
	var is_high_face_male = (bp=="FACE_MALE" and not is_low_face_male)
	var porn_fema = (bp=="ANUS_EXPOSED" or bp=="FEMALE_GENITALIA_EXPOSED" or bp=="FEMALE_BREAST_EXPOSED")
	var sexy_fem = (bp=="ANUS_COVERED" or bp=="FEMALE_GENITALIA_COVERED" or bp=="BUTTOCKS_EXPOSED")
	var beauty_fem = (is_low_face_male or bp=="FACE_FEMALE" or bp=="BUTTOCKS_COVERED" or bp == "FEMALE_BREAST_COVERED")
	var beta_fem = (bp=="FEET_EXPOSED" or bp=="FEET_COVERED" or bp=="ARMPITS_EXPOSED" or bp=="BELLY_EXPOSED")
	var male = (is_high_face_male or bp=="MALE_BREAST_EXPOSED" or bp=="MALE_GENITALIA_EXPOSED")
	
	if porn_fema: return 0
	if sexy_fem: return 1
	if beauty_fem: return 2
	if beta_fem: return 3
	if male: return 4
	return -1
	

func new_detections(detections):
	var current_time_detection = Time.get_ticks_msec()
	self.sec_between_detection = (current_time_detection - time_last_detection) / 1000.0
	self.time_last_detection = current_time_detection
	var detections_array = JSON.parse_string(detections)
	overlay.beta_voices.comment_detections(detections_array)
	check_eco_mode(detections_array)
	if not game_data.game_mode:
		return
	if len(detections_array) == 0:
		current_screen_score_diff = -0.7
	for d in detections_array:
		var d_class = d["class"]
		var d_score = d["score"]
		var d_box = d["box"]
		current_screen_score_diff += update_score_from_detection(d_class, d_score, d_box)
	current_screen_score_diff *= sec_between_detection
	add_score(current_screen_score_diff)

func update_score_from_detection(d_class, d_score, d_box):
	var box_area = d_box[2] * d_box[3]
	var censor_type = censor_type_of_part(d_class, d_score)
	var area_coeff = clamp(15.0*box_area/overlay.screen_area, 0.5, 1.5)
	const type_to_score = {0: 10.0, 1: 6.0, 2: 3.0, 3: 1.5, 4: -4.0, -1: 0.0}
	var score_diff = area_coeff * type_to_score[censor_type]
	return score_diff

func add_score(score_diff):
	game_data.score += score_diff
	if game_data.score > BetaData.get_score_next_lvl():
		trigger_warning()
		return
	if game_data.score < -BetaData.get_score_next_lvl():
		trigger_lower_lvl()
		return

func trigger_warning():
	if is_warning:
		return
	is_warning = true
	overlay.warning_message.start_count_down()
	

func trigger_harder_lvl():
	game_data.score = 1
	game_data.lvl = min(3, game_data.lvl+1)
	make_screen_glitched()
	await get_tree().create_timer(1).timeout
	overlay.beta_voices.get_node("lvl"+str(game_data.lvl)).play()

func trigger_lower_lvl():
	game_data.score = 1
	game_data.lvl = max(-1, game_data.lvl-1)
	overlay.beta_voices.get_node("lowerlvl").play()

func make_screen_glitched():
	overlay.add_child(full_screen_glitched_scn.instantiate())


func set_game_mode(is_game_mode):
	game_data.game_mode = is_game_mode
	overlay.overlay_hud.visible = is_game_mode and game_data.hud_visible
	if is_game_mode and game_data.score > 0:
		make_screen_glitched()


func must_censor_detection(detection):
	# not used
	if not game_data.game_mode:
		# use custom censor settings
		return false
	var censor_type = censor_type_of_part(detection["class"], detection["score"])
	if censor_type == 4 or censor_type == -1:
		return false
	return censor_type <= game_data.lvl

func get_censor_scn_for_detection(detection):
	if not game_data.game_mode:
		# use custom censor settings
		return TEXT_CENSOR_BOX
	# porn_fema: 0, sexy_fem: 1, beauty_fem: 2, beta_fem: 3
	var lvl0 = {0: GLITCHED_BOX, 1: SUBLIM_MESSAGE_BOX, 2: SUBLIM_MESSAGE_BOX if randf()<0.2 else null, 3: null}
	const lvl1 = {0: TEXT_CENSOR_BOX, 1: GLITCHED_BOX, 2: SUBLIM_MESSAGE_BOX, 3: null}
	const lvl2 = {0: TEXT_CENSOR_BOX, 1: TEXT_CENSOR_BOX, 2: GLITCHED_BOX, 3: null}
	const lvl3 = {0: TEXT_CENSOR_BOX, 1: TEXT_CENSOR_BOX, 2: GLITCHED_BOX, 3: SUBLIM_MESSAGE_BOX}
	var censor_lvls = [lvl0, lvl1, lvl2, lvl3]
	var censor_type = censor_type_of_part(detection["class"], detection["score"])
	if game_data.lvl == -1:
		return null
	#if censor_type == 4 or censor_type == -1:
		#return null
	var censor_lvl: Dictionary = censor_lvls[game_data.lvl]
	return censor_lvl.get(censor_type)

func update_warning(is_no_detection):
	if not is_no_detection:
		overlay.warning_message.total_sec_with_no_detection = 0
	else:
		overlay.warning_message.total_sec_with_no_detection += sec_between_detection
		if overlay.warning_message.total_sec_with_no_detection > 1.1:
			overlay.warning_message.play_success()
			overlay.warning_message.stop()
			game_data.score = game_data.score / 2.0

func new_fullscreen_text_texture(new_text: String):
	var text_creator: FSTextCreator = FULL_SCREEN_TEXT_CREATOR.instantiate()
	text_creator.set_size_and_text(overlay.screen_size, new_text)
	overlay.add_child(text_creator)

func update_fullscreen_text_texture_material(new_texture):
	TEXT_CENSOR_BOX.instantiate().get_child(0).material.set_shader_parameter("fs_text_texture", new_texture)

func check_eco_mode(detections_array):
	if is_eco_active:
		if len(detections_array) > 0:
			overlay.tcp_listner.restart_detector(game_data.cd_detections)
			is_eco_active = false
		return
	# is_eco_active == false
	if not game_data.eco_detections:
		return
	if len(detections_array) > 0:
		duration_without_detections = 0
		return
	duration_without_detections += sec_between_detection
	if duration_without_detections > 10:
		overlay.tcp_listner.restart_detector(5)
		is_eco_active = true

func get_score_next_lvl():
	return score_next_lvl * (1 + abs(game_data.lvl))


func rescale_detection(detection, sx, sy):
	sx = clamp(sx, 0.01, 100)
	sy = clamp(sy, 0.01, 100)
	var new_size_x = sx * detection["box"][2]
	var new_size_y = sy * detection["box"][3]
	var new_box = [
		detection["box"][0] - new_size_x*(1.0/sx - 1)/2,
		detection["box"][1] - new_size_y*(1.0/sy - 1)/2,
		new_size_x,
		new_size_y,
	]
	detection["box"] = new_box
	
func get_custom_censor_scn_for_detection(detection):
	# not used
	return game_data.custom_censors.get(detection["class"])
