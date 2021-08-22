extends RayCast

var mass_limit = 50
var throw_force = 5

var object_grabbed = null

var can_use = true

var text_visible = false

# This variable has been made to avoid grabbing and throwing at the same time
var throw_pressed = false

func _ready():
	$GrabText.modulate = Color(1, 1, 1, 0)

func _physics_process(delta):
	if not object_grabbed and get_collider() is RigidBody and get_collider().mass <= mass_limit and not get_collider() is VehicleBody:
		grab_text_appears()
	else:
		grab_text_disappears()
	
	if object_grabbed:
		var vector = $GrabPosition.global_transform.origin - object_grabbed.global_transform.origin
		object_grabbed.linear_velocity = vector * 10
		object_grabbed.axis_lock_angular_x = true
		object_grabbed.axis_lock_angular_y = true
		object_grabbed.axis_lock_angular_z = true
		
		if vector.length() >= 3:
			object_grabbed.set_mode(0)
			release()
	
	# Grab or drop
	if Input.is_key_pressed(KEY_E) or Input.is_joy_button_pressed(0, JOY_XBOX_Y):
		if can_use:
			can_use = false
			if not object_grabbed:
				if get_collider() is RigidBody and get_collider().mass <= mass_limit and not get_collider() is VehicleBody:
					object_grabbed = get_collider()
					object_grabbed.rotation_degrees.x = 0
					object_grabbed.rotation_degrees.z = 0
					if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.6:
						throw_pressed = true
						print(throw_pressed)
			else:
				release()
	else:
		can_use = true
	
	if throw_pressed:
		if not Input.is_mouse_button_pressed(BUTTON_LEFT) and not Input.get_joy_axis(0, 7) >= 0.6:
			throw_pressed = false
	# Throw
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.6:
		if object_grabbed and not throw_pressed:
			object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
			release()

func release():
	object_grabbed.axis_lock_angular_x = false
	object_grabbed.axis_lock_angular_y = false
	object_grabbed.axis_lock_angular_z = false
	object_grabbed = null

func grab_text_appears():
	if not text_visible:
		text_visible = true
		var animation_speed = 0.25
		$GrabTween.interpolate_property($GrabText, "margin_top", 45, 35, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.interpolate_property($GrabText, "modulate", Color(1, 0.5, 0, 0), Color(1, 0.5, 0, 1), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.start()

func grab_text_disappears():
	if text_visible:
		text_visible = false
		var animation_speed = 0.25
		$GrabTween.interpolate_property($GrabText, "margin_top", 35, 45, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.interpolate_property($GrabText, "modulate", Color(1, 0.5, 0, 1), Color(1, 0.5, 0, 0), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.start()
