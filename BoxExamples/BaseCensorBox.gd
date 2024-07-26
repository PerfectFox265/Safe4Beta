class_name BaseCensorBox 

extends Node2D

var class_detect = ""
var score_detect = -1
var box_detect = [-1, -1, -1, -1]


func _ready():
	const MARGIN = 0.1
	var margin_x = MARGIN * box_detect[2]
	var margin_y = MARGIN * box_detect[3]
	position = Vector2(box_detect[0] - margin_x, box_detect[1] - margin_y)
	$TextureRect.size = Vector2(box_detect[2] + 2*margin_x, box_detect[3] + 2*margin_y)
