extends Control

var total_sec_with_no_detection = 0

func _ready():
	z_index = 1

func start_count_down():
	visible = true
	total_sec_with_no_detection = 0
	$Timer.start()
	$AudioStreamPlayerBeep.play()
	BetaData.overlay.beta_voices.start_cd()

func _on_timer_timeout():
	BetaData.trigger_harder_lvl()
	stop()

func stop():
	visible = false
	$Timer.stop()
	BetaData.is_warning = false


func play_success():
	$AudioStreamPlayerSuccess.play()
