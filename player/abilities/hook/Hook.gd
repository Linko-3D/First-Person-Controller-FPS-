extends RayCast

var pull_force = 5

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var grab = get_tree().get_root().find_node("Grab", true, false)

var destination
var can_use = true
var can_use_input = true
var mass_limit = 50

func _physics_process(delta):
	if is_colliding():
		$Position3D.look_at(get_collision_point(), Vector3.UP)
	
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) or Input.is_joy_button_pressed(0, JOY_R):
		if can_use_input and can_use:
			if get_collider() is StaticBody or get_collider() is CSGPrimitive or (get_collider() is RigidBody and get_collider().mass > mass_limit):
				if not destination:
					destination = get_collision_point()
			elif get_collider() is RigidBody and get_collider().mass <= mass_limit:
				var vector = global_transform.origin - get_collider().global_transform.origin
				get_collider().linear_velocity = vector * 1.5
			can_use = false
			can_use_input = false
			$CanHook.border_width = 3
	else:
		destination = null
		can_use_input = true
		$CanHook.border_width = 2
	
	if destination:
		var vector = (destination - player.global_transform.origin)
		player.move_and_slide(vector * pull_force)

	if not can_use:
		if $Timer.is_stopped() and not destination:
			$CanHook.border_color = Color(0, 0, 0, 0)
			$Timer.start()
	else:
		if is_colliding():
			$CanHook.border_color = Color(0, 1, 1, 0.5)
		else:
			$CanHook.border_color = Color(0, 0, 0, 0)
			
func _on_Timer_timeout():
	can_use = true
