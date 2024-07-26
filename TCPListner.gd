extends Node

const DETECTOR_PATH = "./nudenet/output/screen-detect-nude/screen-detect-nude.exe"

var server := TCPServer.new()
var client: StreamPeerTCP = null
var pid_detector = -1

func _ready():
	server.listen(16996, "127.0.0.1")
	# the detector will be launched by the config menu after reading the params
	#pid_detector = OS.create_process(DETECTOR_PATH, [get_parent().TIME_BETWEEN_DETECTION])

func _exit_tree():
	server.stop()
	OS.kill(pid_detector)

func _process(_delta):
	if server.is_connection_available():
		client = server.take_connection()
		print("New connection. IP : ", client.get_connected_host())
		if client.get_connected_host() != "127.0.0.1":
			printerr("external IP not allowed")
			return
		BetaData.time_last_detection = Time.get_ticks_msec()
	if client != null and client.get_status() == StreamPeerTCP.STATUS_CONNECTED and client.get_available_bytes() > 0:
		var detections = client.get_utf8_string(client.get_available_bytes())
		print("Detections: ", detections)
		BetaData.new_detections(detections)
		BetaData.overlay.draw_censor(detections)

func restart_detector(time_between_detection):
	if pid_detector != -1:
		OS.kill(pid_detector)
	pid_detector = OS.create_process(DETECTOR_PATH, [time_between_detection])
	print("Detector now use ", time_between_detection, " sec CD.")
	
