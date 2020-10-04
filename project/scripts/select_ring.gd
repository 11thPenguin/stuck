extends Node2D

var player = null

func bind_player(node) :
	player = node


func open() :
	position = get_global_mouse_position()
	#print("Opening @ %s" % position)

	_update_pip()

	$AnimationPlayer.play("zoom_in")
	visible = true


func _close(do_launch) :
	$AnimationPlayer.play("zoom_out")
	visible = false

	if do_launch :
		_launch()


func _launch() :
	var mouse_pos = get_global_mouse_position()
	var launch_rad = mouse_pos.angle_to_point(position)
	player.launch(launch_rad)


func _update_pip() :
	var mouse_pos = get_global_mouse_position()
	$Pip.rotation = mouse_pos.angle_to_point(position)


func _input(event) :
	if not visible :
		return

	if event is InputEventMouseButton :
		if event.button_index == BUTTON_LEFT and not event.pressed :
			_close(true)
		elif event.button_index == BUTTON_RIGHT and event.pressed :
			_close(false)

	elif event is InputEventMouse :
		_update_pip()


