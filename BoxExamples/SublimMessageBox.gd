extends BaseCensorBox
@export var textCensor: String = "Beta Keep Out "
@export var timer: float = 0.1

const messages = [
	"Keep Out",
	"Look Away",
	"Not for Beta",
	"Not for You",
	"No Losers",
	"Denied",
	"Forbidden",
]
func _ready():
	super._ready()
	var font_size = int($TextureRect.size.y/6)
	$TextureRect.position += Vector2((randf()-0.5)*0.2*$TextureRect.size.x, (randf()-0.5)*0.2*$TextureRect.size.y)
	$TextureRect/Label.add_theme_font_size_override("font_size", font_size)
	timer += 1.0
	hide_text()


func set_text():
	visible = true
	var message = messages[randi_range(0, len(messages)-1)]
	$TextureRect/Label.text = message
	$Timer.start(1.0/15.0)
	
func hide_text():
	visible = false
	var U = randf()
	$Timer.start(-timer * log(1.0 - U))


func _on_timer_timeout():
	if visible:
		hide_text()
	else:
		set_text()
