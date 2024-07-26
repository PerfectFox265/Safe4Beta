extends Sprite2D

var y_ground
var screen_width

var direction = -1
var speed_y = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos_x = position.x
	pos_x += direction * 500 * delta
	if (pos_x < 0 or screen_width < pos_x):
		direction *= -1
	
	var pos_y = position.y
	speed_y = max(-2000 , speed_y - 50)
	if Input.is_action_just_pressed("ui_accept"): 
		speed_y = 500
	pos_y = min(y_ground, pos_y - delta * speed_y)
	
	position = Vector2(pos_x, pos_y)
