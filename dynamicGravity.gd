extends Area2D

@export var rot : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.justTeleported == true: # teleported into field
		body.canTeleport = false
		var currVelocity = body.velocity
		var newGravity = currVelocity.rotated(rot) * 1.25
		newGravity.y *= 1.5
		
		body.velocity = newGravity
		body.gravityVector = newGravity
	


func _on_body_exited(body):
	body.gravityVector.y = min(3000, body.gravityVector.y)
	$Timer.start(0.1)
	await($Timer.timeout)
	body.gravityVector = Vector2(0, 3000) # Normal Gravity
	
	print(body.gravityVector)
