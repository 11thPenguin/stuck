extends Node2D

const LAUNCH_SPEED = 500
const REEL_SPEED = 450

const ARM_LENGTH = 300
const STRENGTH = Vector2(300, 0)
const ATTACH_TIME = 1.5

var retracted = true
var extending = false

var attach_point = null
var was_attached = false

var grabber_normal
var velocity = Vector2.ZERO


func _ready() :
	grabber_normal = position.normalized()


func launch(launch_rad) :
	if !retracted :
		return

	velocity = Vector2(LAUNCH_SPEED, 0.0).rotated(launch_rad)

	retracted = false
	was_attached = false

	extending = true


func _physics_process(delta) :
	if !extending and !attach_point :
		if retracted :
			return

		# If the hand isn't extending or attached, and isn't retracted, reel it in!
		if $Hand.position.length() < 2.0 :
			_redock()
		else :
			var hand_pos = $Hand.position
			var hand_dir = hand_pos.dot(grabber_normal)
			if hand_dir >= 0 :
				var reel = Vector2(REEL_SPEED, 0.0).rotated(hand_pos.angle())
				_set_hand_pos($Hand.position - reel * delta)
			else :
				_redock()

		return

	# Don't restick -- if we were attached once, we need to be launched again.
	if !attach_point and !was_attached :
		var collision = $Hand.move_and_collide(velocity * delta)
		if collision :
			#print("%s hit %s @ %s!" % [name, collision.collider.name, collision.position])
			_attach(collision.position)

	# Keep the line synced up.
	$Arm.points[1] = $Hand.position

	# A quick an dirty raycast along the arm to see if we've passed behind anything.
	var space_state = get_world_2d().direct_space_state
	var raycast_result = space_state.intersect_ray(global_position, $Hand.global_position, [get_parent(), self, $Hand])
	if raycast_result :
		var cast_off = $Hand.global_position - raycast_result.position
		# Don't worry about things that are "nearish" to the hand.
		if cast_off.length() > 10.0 :
			#print("%s intersected %s at %s" % [name, raycast_result.collider.name, raycast_result.position])
			_set_hand_pos(raycast_result.position - global_position)
			_detach()

			return

	var hand_pos = $Hand.position

	# Dot the angle of the arm with the normal and detach if it's too steep
	var hand_dir = hand_pos.dot(grabber_normal)
	# JASNOTE: I have no idea what a "good" value for this is?!
	if hand_dir <= 0.6 :
		#print("Detaching %s before it breaks!" % name)
		_detach()

	elif !attach_point :
		if hand_dir >= 0 :
			var extension = hand_pos.length() / ARM_LENGTH
			var pull = extension * STRENGTH
			pull = pull.rotated(hand_pos.angle())
			#print(extension, pull)

			velocity -= pull * delta
		else :
			_redock()

	else :
		var hand_off = attach_point - global_position
		# If the hand is almost home, let go!
		if hand_off.length() < 2.0 :
			_detach()

		else :
			# Keep the hand stuck to the wall (grabber parent may have moved).
			_set_hand_pos(hand_off)

			# Give parent some tug.
			var extension = hand_off.length() / ARM_LENGTH
			var pull = extension * STRENGTH
			pull = pull.rotated(hand_off.angle())

			# JASNOTE: I can't decide if "delta" here is just a convenient damping factor?
			get_parent().apply_central_impulse(pull * delta)


func _set_hand_pos(hand_pos) :
	$Hand.position = hand_pos
	$Arm.points[1] = hand_pos


func _attach(attach_position) :
	#print("Attaching %s @ %s" % [name, attach_position])

	if attach_point :
		print("ALREADY ATTACHED!")
		return

	# Stick hand to surface we grabbed.
	attach_point = attach_position
	velocity = Vector2.ZERO

	extending = false
	was_attached = true

	$AttachTimer.start(ATTACH_TIME)

	# Give our parent a tug.
	var hand_off = attach_point - global_position
	var extension = hand_off.length() / ARM_LENGTH
	var pull = extension * STRENGTH
	pull = pull.rotated(hand_off.angle())

	get_parent().apply_central_impulse(pull)


func _detach() :
	#print("Detaching %s" % name)

	velocity = Vector2.ZERO

	if attach_point :
		var hand_off = attach_point - global_position
		if hand_off.length() < 2.0 :
			_redock()

		attach_point = null

	extending = false

	$AttachTimer.stop()


func _redock() :
	_set_hand_pos(Vector2.ZERO)
	was_attached = false
	retracted = true


func _on_AttachTimer_timeout() :
	_detach()
