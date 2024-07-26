@tool
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var game_data := {
	score = 1,
	audio = true,
	}
	print(game_data.score)
	print(JSON.stringify(game_data))
	print(game_data.keys())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
