extends CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.8
const LOOKSENSE := 0.0025 * 4

@onready var camera: Camera3D = $Camera3D
#@onready var raycast : RayCast3D = $Camera3D/RayCast3D

var paused := false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	
func _physics_process(delta):
	

	#camera.rotation.x = lerp($Camera3D.rotation.x, camera_smooth.rotation.x,delta * 3);
	#camera.rotation.y = lerp(camera.rotation.y, camera_smooth.rotation.y,delta * 3);$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI / 2, PI / 2);
	update_mouse_mode()
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED 

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
   
	move_and_slide()






func update_mouse_mode():
	
	if paused:

		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):

	if event is InputEventMouseMotion:
		if not paused:
			rotate_y( - event.relative.x * LOOKSENSE)
			camera.rotate_x( - event.relative.y * LOOKSENSE)
			camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
	
	if event.is_action_pressed("esc"):
		paused = !paused
		update_mouse_mode()
