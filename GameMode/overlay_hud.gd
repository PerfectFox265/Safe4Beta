extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var score_ratio = BetaData.game_data.score / BetaData.get_score_next_lvl()
	var score_percentage = snapped(score_ratio * 100.0, 1)
	var prefix = "Punishment : " if score_ratio >= 0 else "Reward : "
	var neutral_col = Color.WHITE
	var max_color = Color.RED if BetaData.current_screen_score_diff > 0 else Color.GREEN
	$HBoxContainer/Label.text = prefix + str(abs(score_percentage)) + "%"
	const max_screen_score = 30.0
	$HBoxContainer/TextureRect.modulate = neutral_col.lerp(max_color, clamp(abs(BetaData.current_screen_score_diff)/max_screen_score, 0., 1.))
	
