extends CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.8
const LOOKSENSE := 0.0025

@onready var camera: Camera3D = $Camera3D
#@onready var raycast : RayCast3D = $Camera3D/RayCast3D

var paused := false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#headbob
var headbobSpeed : float = 2; #headbobs per second
var headbobTimer : float = 0;
const headbobLength : float = 0.2;

#sprint
const sprintMuti : float = 1.45;
func _ready() -> void:
	update_mouse_mode()
func _physics_process(delta):
	


	# Add the gravity.
	handle_crouch(delta)
	headbob(delta)
	if not is_on_floor():
		velocity.y -= gravity * delta

	var isSprinting = Input.is_action_pressed("sprint")
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED * (sprintMuti if isSprinting else 1.0)
		velocity.z = direction.z * SPEED * (sprintMuti if isSprinting else 1.0)

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
   
	move_and_slide()



func handle_crouch(delta):
	var is_crouched = Input.is_action_pressed("ctrl")


	if(!is_crouched and $upward_check.is_colliding()):
		is_crouched = true
	$CollisionShape3D.shape.height = 1 if is_crouched else 2
	$CollisionShape3D.position.y = -0.5 if is_crouched else 0.0
	var t = get_tree().create_tween()

	if(is_crouched):
		t.tween_property($Camera3D, "position", Vector3.UP * 0, delta * 15)
	else:
		t.tween_property($Camera3D, "position", Vector3.UP * (sin(headbobTimer) * headbobLength + 1), delta * 15)

func headbob(delta):
	if(velocity.x + velocity.z != 0):
		headbobTimer += delta * headbobSpeed * (sprintMuti if Input.is_action_pressed("sprint") else 1.0)
	if(headbobTimer>PI):
		headbobTimer = 0;


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
