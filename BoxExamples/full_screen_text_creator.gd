class_name FSTextCreator
extends SubViewport

@export var textCensor: String = "Beta Keep Out "
var _texture = null

# Called when the node enters the scene tree for the first time.
func _ready():
	await RenderingServer.frame_post_draw
	_texture = get_texture()
	BetaData.update_fullscreen_text_texture_material(_texture)


func set_size_and_text(fs_size: Vector2i, text: String):
	size = fs_size
	textCensor = text
	$TextureRect.size = fs_size  # warning but work only this way
	const char_area = 20*8
	var texture_area = ($TextureRect.size.x + 10) * $TextureRect.size.y
	var nbr_repeat_text = 2 + texture_area / (len(textCensor) * char_area)
	$TextureRect/RichTextLabel.text = textCensor.repeat(int(nbr_repeat_text))
