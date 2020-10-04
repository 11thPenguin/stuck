extends Control


signal next_button

func _on_NextButton_pressed() :
	emit_signal("next_button")
