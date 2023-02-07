extends CharacterBody2D

const ACCELERATION = 3000
const MAX_SPEED = 15000 # Changed this value
const LIMIT_SPEED_Y = 100000
const JUMP_HEIGHT = 34000
const MIN_JUMP_HEIGHT = 1200
const MAX_COYOTE_TIME = 6
const JUMP_BUFFER_TIME = 10
var gravity_reversed = false
const WALL_JUMP_AMOUNT = 18000
const WALL_JUMP_TIME = 10
const WALL_SLIDE_FACTOR = 0.8
const WALL_HORIZONTAL_TIME = 30
const GRAVITY = 2100
const DASH_SPEED = 36000

var gravityVector = Vector2(0,3000)
var previousVelocity = Vector2(0,0)
var normalGravity = true
var justTeleported = false;
var accelerationVector = Vector2(0,0)

var axis = Vector2()

var coyoteTimer = 0
var jumpBufferTimer = 0
var wallJumpTimer = 0
var wallHorizontalTimer = 0
var dashTime = 0

var spriteColor = "red"
var canJump = false
var friction = false
var wall_sliding = false
var dying = false : set = deathMethod
var trail = false
var isDashing = false
var hasDashed = false
var isGrabbing = false

var canTeleport = false;


func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale;
	await(get_tree().create_timer(duration * timeScale).timeout)
	Engine.time_scale = 1.0


func deathMethod(deathLoc: bool):
	await(frameFreeze(0.05,1.5))
	position = Vector2(50,-50)
	dying = false

func test():
	$teleportTimer.start(0.1)
	await($teleportTimer.timeout)
	justTeleported = false

func _physics_process(delta):
	
	# Calculate Properties
	accelerationVector = (velocity - previousVelocity) / delta
	previousVelocity = velocity
	
	
	
	if is_on_floor():
		canJump = true
		canTeleport = true
		coyoteTimer = 0
	else:
		coyoteTimer += 1
		if coyoteTimer > MAX_COYOTE_TIME:
			coyoteTimer = 0
			# remove canJump = False
		friction = true

	if(gravity_reversed):
		if(is_on_ceiling()):
			canJump = true;
			canTeleport = true;
	#print(can_teleport)
	$topRaycast.target_position = get_global_mouse_position()-$topRaycast.global_position
	$bottomRaycast.target_position = get_global_mouse_position() - $bottomRaycast.global_position + Vector2(0,32)
	if(Input.get_action_strength("teleport") and canTeleport):
		Engine.time_scale = 0.05
	if(Input.is_action_just_released("teleport") and canTeleport):
		Engine.time_scale = 1.0

		if($topRaycast.get_collider() != null and $bottomRaycast.get_collider() != null):
			print("you cant teleport here")
		else:
			position = get_global_mouse_position()
			canTeleport = false
			
			# For teleporting into fields
			justTeleported = true
			test()
			
	
	
	
	
	if velocity.y <= LIMIT_SPEED_Y:
		if(gravity_reversed):
			
			velocity -= gravityVector * delta
		else:
			velocity += gravityVector * delta

	friction = false
	
	getInputAxis()
	

	#basic vertical movement mechanics
	if wallJumpTimer > WALL_JUMP_TIME:
		wallJumpTimer = WALL_JUMP_AMOUNT
		if !isDashing && !isGrabbing:
			horizontalMovement(delta)
	else:
		wallJumpTimer += 1
	
	###if !canJump:
	##	if !wall_sliding:
	##		if velocity.y >= 0:
	#			$AnimationPlayer.play(str(spriteColor, "Fall"))
	##		elif velocity.y < 0:
	#			$AnimationPlayer.play(str(spriteColor, "Jump"))

	#jumping mechanics and coyote time

	
	jumpBuffer(delta)
	if Input.is_action_just_released("jump"):
		velocity.y = lerp(velocity.y, 0.01, 0.3)
	if Input.is_action_just_pressed("jump"):
		if canJump:
			jump(delta)
			frictionOnAir()
		else:
			frictionOnAir()
			jumpBufferTimer = JUMP_BUFFER_TIME #amount of frame
		
		
		

	setJumpHeight(delta)
	jumpBuffer(delta)

	move_and_slide()

func jump(delta):
	canJump = false # add something here
	if(gravity_reversed):
		velocity.y = JUMP_HEIGHT * delta
	else:
		velocity.y = -JUMP_HEIGHT * delta
	


func frictionOnAir():
	if friction:
		pass
		#velocity.x = lerp(velocity.x, 0.0001, 0.1)

func jumpBuffer(delta):
	if jumpBufferTimer > 0:
		if is_on_floor():
			jump(delta)
		jumpBufferTimer -= 1

func setJumpHeight(delta):
	if Input.is_action_just_released("ui_up"):
		
		if velocity.y < -MIN_JUMP_HEIGHT * delta:
			velocity.y = -MIN_JUMP_HEIGHT * delta

func horizontalMovement(delta):
	if Input.is_action_pressed("ui_right"):
		if $RayCast2D.is_colliding():
			#await(get_tree().create_timer(0.1),"timeout")
			await(get_tree().create_timer(0.1))
			velocity.x = min(velocity.x + ACCELERATION * delta, MAX_SPEED * delta)


		else:
			velocity.x = min(velocity.x + ACCELERATION * delta, MAX_SPEED * delta)



	elif Input.is_action_pressed("ui_left"):
		if $RayCast2D.is_colliding():
			#yield(get_tree().create_timer(0.1),"timeout")
			await(get_tree().create_timer(0.1))
			velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			#$Rotatable.scale.x = -1
		else:
			velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			###$Rotatable.scale.x = -1

	else:
		if canJump == true:
			velocity.x = lerp(velocity.x, 0.01, 0.4)



func getInputAxis():
	axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	axis = axis.normalized()







func _on_hitbox_area_entered(area):
	if(area.get_name() == "upgrav ffield"):
		gravity_reversed = true



func _on_hitbox_area_exited(area):
	if(area.get_name() == "upgrav ffield"):
		gravity_reversed = false
