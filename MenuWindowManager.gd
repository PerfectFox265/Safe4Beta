extends Node

var win
var is_win_visible = false
const menu = preload("res://Menu.tscn")

# This node create a new native window when the game is focused so we can click on buttons
# bug if we try to set this window in godot editor

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_window().focus_entered.connect(window_focus)
	#get_window().focus_exited.connect(window_unfocus)
	win = Window.new()
	win.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	win.mode = Window.MODE_MINIMIZED
	win.size = Vector2i(430, 600)
	win.min_size = Vector2i(430, 430)
	win.title = "Safe for Beta - Menu"
	win.add_child(menu.instantiate())
	add_child(win)
	win.position += Vector2i(400, 0)

