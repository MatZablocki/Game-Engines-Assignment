extends CharacterBody3D


const SPEED = 1.2
const JUMP_VELOCITY = 3

@export var MOUSE_SENSITIVITY : float = 0.3
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var Env : Environment
var mouse_input : bool = false
var rotation_input : float
var tilt_input : float
var mouse_rotation : Vector3
var player_rotation : Vector3
var camera_rotation : Vector3
var footsteps
var fullscreen : bool = false
var hint
var end = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	if event.is_action_pressed("interact") and end:
		var temp = get_parent()
		temp.get_node("WorldEnvironment").set_environment(Env)
		temp.get_node("WinCamera").make_current()
		temp.get_node("ScaryMusic").stop()
		temp.get_node("HappyMusic").play()
		get_node("Spooky").queue_free()
	
	if event.is_action_pressed("fullscreen"):
		if(!fullscreen):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreen = false
	if event.is_action_pressed("test"):
#		var allRooms = get_parent().get_node("Room-holder").get_children()
#		for room in allRooms:
#			if is_instance_valid(room):
#				room.queue_free()
		#get_node("Spooky").position += Vector3(0,0,1)
		pass

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	footsteps = get_node("AudioStreamPlayer")
	hint = get_node("Camera3D/Sprite3D2")

func _unhandled_input(event):
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		rotation_input = -event.relative.x
		tilt_input = -event.relative.y

func _update_camera(delta):
	mouse_rotation.x += tilt_input * delta * MOUSE_SENSITIVITY
	mouse_rotation.x = clamp(mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouse_rotation.y += rotation_input * delta * MOUSE_SENSITIVITY
	
	player_rotation = Vector3(0.0, mouse_rotation.y, 0.0)
	camera_rotation = Vector3(mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0 
	
	global_transform.basis = Basis.from_euler(player_rotation)
	
	rotation_input = 0.0
	tilt_input = 0.0 

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	_update_camera(delta)
	var raycast = get_node("Camera3D/RayCast3D")
	raycast.force_raycast_update()
	#print("right ", raycast.is_colliding())
	if(raycast.is_colliding()):
		hint.show()
		end = true
	else:
		hint.hide()
		end = false
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if footsteps.playing == false:
			footsteps.play()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		footsteps.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
