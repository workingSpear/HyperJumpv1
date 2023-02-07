extends Area2D

var selfVector = Vector2(0,0)
@export var forceNeeded : float = 500


# Called when the node enters the scene tree for the first time.
func _ready():
	# Calculate Vector
	selfVector = ($top.global_position - $bottom.global_position)
	selfVector *= 1/selfVector.length()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	


func _on_body_entered(body):
	print(selfVector)

	

	var vel = body.velocity / body.velocity.length()
	
	var dot_product = vel.dot(selfVector)
	var vec1_magnitude = vel.length()
	var vec2_magnitude = selfVector.length()

	var cos_theta = dot_product / (vec1_magnitude * vec2_magnitude)
	var angle = acos(cos_theta)
	
	

	var c = (-4 / pow(PI, 2))
	print(angle)
	print((c * pow((angle - (PI/2)),2) + 1))
	var totalForce = (c * pow((angle - (PI/2)),2) + 1) * body.velocity.length()
	# This is done wrong
	
	print(totalForce)
	
	if totalForce >= forceNeeded:
		visible = false
		$testTimer.start(1.5)
		await($testTimer.timeout)
		visible = true
	
	
	
	



