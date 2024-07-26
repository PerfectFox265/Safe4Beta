extends Node

var on_cd = true

func _ready():
	start_cd()

func to_higher_lvl():
	# not used
	var lvl: int = BetaData.game_data.lvl
	get_node("lvl"+str(lvl)).play()

var type_to_node = {
	0: "basic",
	1: "basic",
	2: "basic",
}

func comment_detections(detections_array):
	if on_cd:
		return
	for d in detections_array:
		var d_class = d["class"]
		var d_score = d["score"]
		#var d_box = d["box"]
		var type = BetaData.censor_type_of_part(d_class, d_score)
		var str_node = type_to_node.get(type)
		if str_node == null:
			continue
		get_node(str_node).play()
		start_cd()
		return

func start_cd():
	var cd = BetaData.game_data.cd_comments
	on_cd = true
	$Timer.start(cd * (1 + randf()*0.25))

func _on_timer_timeout():
	on_cd = false
