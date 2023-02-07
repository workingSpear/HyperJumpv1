extends Area2D

@export var freezeSeconds = 0.5;

func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale;
	await(get_tree().create_timer(duration * timeScale).timeout)
	Engine.time_scale = 1.0

func _on_body_entered(body):
	if(visible and body.canTeleport == false):
		print("Collided Withself")
		frameFreeze(0.01,freezeSeconds)
		body.canTeleport = true
		visible = false
		$visibleTimer.start(4)
		await($visibleTimer.timeout)
		print("timed out")
		visible = true
		
	

	

func _on_mouse_entered():
	pass # Replace with function body.



