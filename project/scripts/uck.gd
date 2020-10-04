extends Area2D


func _on_Uck_body_entered(body) :
	print("Entered uck!")
	body.pickup_uck()

	queue_free()
