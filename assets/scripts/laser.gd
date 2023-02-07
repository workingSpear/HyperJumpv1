extends RayCast2D



var is_casting := false : set = set_is_casting

func _ready():
	set_physics_process(false)
	$LaserSpriteSheet.frame = 0

func _process(delta):
	if(get_collider().get_name() == "thing" && $Line2D.width == 5.0):
		get_collider().dying = true;
	$text/RichTextLabel.text = "Timer: " + str(round($LaserTimer.time_left))

func _physics_process(delta: float)-> void:
	var cast_point = target_position
	force_raycast_update()
	
	$collisionParticles.emitting = is_colliding()
	
	if(is_colliding()):
		cast_point = to_local(get_collision_point())
		$collisionParticles.global_rotation = get_collision_normal().angle()
		$collisionParticles.position = cast_point
	
	$Line2D.set_point_position(1, cast_point) 
	$beamParticles.position = cast_point * 0.5
	$beamParticles.process_material.emission_box_extents.x = cast_point.length() * 0.5
	
	
func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	$beamParticles.emitting = is_casting
	$castingParticle.emitting = is_casting
	if(is_casting):
		appear()
	else:
		$collisionParticles.emitting = false
		disappear()
		$WorldEnvironment.environment.glow_enabled = false
	set_physics_process(is_casting)
	
	

func appear()->void:
	var tween = get_tree().create_tween()
	tween.stop()
	tween.tween_property($Line2D, "width",5.0, 1.1)
	$AnimationPlayer.play("laserActivate")
	tween.play()
	await($Line2D.width == 5.0)
	$WorldEnvironment.environment.glow_enabled = true

func disappear():
	var tween = get_tree().create_tween()
	tween.tween_property($Line2D, "width", 0 , 0.2)
	$LaserSpriteSheet.frame = 0
	tween.play()


func _on_laser_timer_timeout():
	is_casting = !is_casting
