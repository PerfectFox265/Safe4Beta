extends Node

var win
const menu = preload("res://Menu.tscn")

# This node create a new native window when the game is focused so we can click on buttons
# bug if we try to set this window in godot editor

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_window().focus_entered.connect(window_focus)
	#get_window().focus_exited.connect(window_unfocus)
	win = Window.new()
	var window_id = get_tree().get_root().get_window_id()
	var id_screen = DisplayServer.window_get_current_screen(window_id)
	var screen_size: Vector2i = DisplayServer.screen_get_size(id_screen)
	win.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	win.position = Vector2i(screen_size.x-500, screen_size.y-700)
	win.min_size = Vector2i(1, 1)
	win.size = Vector2i(1, 1)
	win.title = "Safe for Beta - Menu"
	win.add_child(menu.instantiate())
	add_child(win)
	win.mode = Window.MODE_MINIMIZED
	await get_tree().create_timer(0.1).timeout
	win.min_size = Vector2i(430, 600)
	win.size = Vector2i(430, 600)
	#win.focus_entered.connect(Callable(window_focus).bind(screen_size))
	#
#func window_focus(screen_size: Vector2i):
	#await get_tree().create_timer(1).timeout
	#
	#win.position = Vector2i(screen_size.x-500, screen_size.y-700)
	#for connection in get_incoming_connections():
		#connection.signal.disconnect(connection.callable)
