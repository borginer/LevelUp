extends Label

var minutes : int = 0
var seconds : int = 0

func _ready() -> void:
	set_clock_text()


func _on_second_timeout() -> void:
	seconds += 1
	if seconds >= 60:
		seconds = 0
		minutes += 1
	set_clock_text()
	
	
func set_clock_text():
	var minutes_zero = "0" if minutes < 10 else ""
	var seconds_zero = "0" if seconds < 10 else ""
	text =  minutes_zero + str(minutes) + ":" + seconds_zero + str(seconds)
