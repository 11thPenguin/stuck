extends Control


signal begin_button

func _on_BeginButton_pressed() :
	emit_signal("begin_button")
