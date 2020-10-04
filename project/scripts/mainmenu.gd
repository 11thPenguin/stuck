extends Control


signal play_button

func _on_PlayButton_pressed() :
	emit_signal("play_button")
