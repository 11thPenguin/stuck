extends KinematicBody2D

signal level_complete

var Protogluck = preload("res://scenes/gluck.tscn")

var velocity = Vector2.ZERO

var glucks = []
var gluck_count = 0


func _ready() :
	# JASNOTE: Easier to do this here than in the editor.
	for i in range(8) :
		var hand_node = find_node("Hand%d" % i)
		var sprite_node = hand_node.find_node("HandSprite")
		sprite_node.rotation = i * 30


func configure_glucks(num_glucks) :
	print("PLAYER: Configuring for %d glucks" % num_glucks)

	while len(glucks) :
		var gluck =	glucks.pop_back()
		gluck.queue_free()

	gluck_count = 0

	var gluck_angle = TAU / num_glucks

	var gluck_pos = Vector2(32.0, 0.0)
	var gluck_rot = 0
	for _i in range(num_glucks) :
		var new_gluck = Protogluck.instance()
		new_gluck.visible = false

		new_gluck.position = gluck_pos
		gluck_pos = gluck_pos.rotated(gluck_angle)

		new_gluck.rotation = gluck_rot
		gluck_rot += gluck_angle

		glucks.append(new_gluck)
		$GluckLoop.add_child(new_gluck)


func launch(launch_rad) :
	launch_rad = stepify(launch_rad, PI/4)
	var launch_dir = launch_rad / (PI/4)
	var launch_ord = posmod(launch_dir, 8)
	#print("LAUNCH @ %s, %s(%s)" % [launch_rad, launch_dir, launch_ord])

	var launch_hand = find_node("Hand%s" % launch_ord)
	launch_hand.launch(launch_rad)


func apply_central_impulse(impulse) :
	velocity += impulse


func _physics_process(delta) :
	var collision = move_and_collide(velocity * delta)
	if collision :
		velocity = Vector2.ZERO

		# Skootch back a bit 'cause we're getting stuck...?
		position += Vector2(0.2, 0.0) * collision.normal


func pickup_uck() :
	if gluck_count < len(glucks) :
		glucks[gluck_count].visible = true
		gluck_count += 1

	if gluck_count == len(glucks) :
		# JASNOTE: This is getting into some JAMmy fixes here.
		gluck_count = 0
		emit_signal("level_complete")
