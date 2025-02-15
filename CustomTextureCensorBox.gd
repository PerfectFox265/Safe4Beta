extends BaseCensorBox

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if BetaData.custom_texture != null:
		$TextureRect.texture = BetaData.custom_texture
