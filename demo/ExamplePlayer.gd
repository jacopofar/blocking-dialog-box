extends KinematicBody2D

# Player movement speed
export var speed: int = 150
export var interaction_range: float = 50.0

var keyboard_pressed: bool = false
var mouse_pressed: bool = false
var touch_pressed: bool = false
var touch_initial_direction: Vector2 =  Vector2(0, 1)

func _physics_process(delta):
	var direction: Vector2
	
	if mouse_pressed:
		direction = position.direction_to(get_global_mouse_position())
	elif touch_pressed:
		direction = touch_initial_direction	
	elif keyboard_pressed:
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		

	# avoid diagonal movement
	if abs(direction.x) > abs(direction.y):
		direction.y = 0
		if direction.x > 0:
			$AnimationPlayer.play("right")
		else:
			$AnimationPlayer.play("left")
	else:
		direction.x = 0
		if direction.y > 0:
			$AnimationPlayer.play("down")
		else:
			$AnimationPlayer.play("up")
	if direction.x == 0 and direction.y == 0:
		$AnimationPlayer.stop()
	else:
		# try a movement only if there is something to do
		direction = direction.normalized()
		var movement = speed * direction * delta
		# warning-ignore:return_value_discarded
		move_and_collide(movement)
		$RayCast2D.cast_to = direction.normalized() * 32
		
	
func _unhandled_input(event):
	# see https://docs.godotengine.org/en/latest/tutorials/inputs/inputevent.html
	var is_interaction = false
	if event.is_action_pressed("interact"):
		is_interaction = true
	if (event.is_action_pressed("ui_down")
		or event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
		):
		keyboard_pressed = true
	if (event.is_action_released("ui_down")
		or event.is_action_released("ui_up")
		or event.is_action_released("ui_left")
		or event.is_action_released("ui_right")
		):
		keyboard_pressed = false

	if event is InputEventScreenTouch:
		touch_pressed = event.is_pressed()
		var world_position = get_canvas_transform().xform_inv(event.position)
		if position.distance_to(world_position) < interaction_range:
			is_interaction = true
			# the intent was not to move, pretend it's not touching to not
			# trigger the movement
			touch_pressed = false
		else:
			touch_initial_direction = position.direction_to(world_position)
			return
	
	if event is InputEventMouseButton and event.pressed:
		if position.distance_to(get_global_mouse_position()) < interaction_range:
			is_interaction = true
		else:
			mouse_pressed = true
	if event is InputEventMouseButton and not event.pressed:
		mouse_pressed = false
	if is_interaction:
		var target = $RayCast2D.get_collider()
		
		if target != null:
			if target.has_method("on_interact"):
				target.on_interact()
			else:
				print_debug("Cannot interact with this")
