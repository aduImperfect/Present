extends CharacterBody3D

@export_group("Movement")
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

@export_group("Camera")
@export var mouse_sensitivity: float = 0.003
@export var controller_look_sensitivity: float = 2.0
@export var tilt_lower_limit: float = -deg_to_rad(60.0)
@export var tilt_upper_limit: float = deg_to_rad(75.0)

@onready var camera_pivot: Node3D = $CamPivot
@onready var spring_arm: SpringArm3D = $CamPivot/CamPitch
@onready var camera: Camera3D = $CamPivot/CamPitch/Camera3D

var cam_rotation: Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cam_rotation.x -= event.relative.y * mouse_sensitivity
		cam_rotation.y -= event.relative.x * mouse_sensitivity
		_clamp_camera_pitch()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Controller rotation look input
	var look_dir = Input.get_vector("camera_left", "camera_right", "camera_down", "camera_up")
	if look_dir != Vector2.ZERO:
		cam_rotation.y -= look_dir.x * controller_look_sensitivity * delta
		cam_rotation.x -= look_dir.y * controller_look_sensitivity * delta
		_clamp_camera_pitch()

	# Apply rotation to pivot
	camera_pivot.rotation.y = cam_rotation.y
	spring_arm.rotation.x = cam_rotation.x

	# Follow player position smoothly or directly
	camera_pivot.global_position = global_position + Vector3(0, 1.5, 0) # Neck/eye offset

	# Get camera basis flattened on Y axis for front-axis movement
	var cam_basis = camera.global_transform.basis
	var forward = -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	var right = cam_basis.x
	right.y = 0.0
	right = right.normalized()

	# Movement input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir = (right * input_dir.x - forward * input_dir.y).normalized()

	if move_dir != Vector3.ZERO:
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
		# Optional: face mesh towards movement direction
		# rotation.y = lerp_angle(rotation.y, atan2(-move_dir.x, -move_dir.z), 15.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _clamp_camera_pitch() -> void:
	cam_rotation.x = clamp(cam_rotation.x, tilt_lower_limit, tilt_upper_limit)
