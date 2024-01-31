extends CharacterBody3D

@onready var camera = $Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#slide vars

var fall_distance = 0 
var slide_speed = 0
var can_slide = false
var sliding = false
var falling = false

@onready var slide_check = $Slide_Check


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .002)
		camera.rotate_x(-event.relative.y * .002)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if falling and is_on_floor() and sliding:
		slide_speed += fall_distance / 10
	fall_distance = -gravity
	 
	
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY



#slide bind
	if Input.is_action_just_pressed("slide") and SPEED > 1:
			can_slide = true
	if Input.is_action_just_pressed("slide") and is_on_floor() and Input.is_action_just_pressed("up") and can_slide:
		slide()


	if Input.is_action_just_pressed("slide"):
		can_slide = false
		sliding = false


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

#BIG MOVEMENT BIG SLIDING YOU KNOW WHAT IT IS 
func slide():
	if not sliding:
		if slide_check.is_colliding() or get_floor_angle() < 0.2:
			slide_speed = 5
			slide_speed += fall_distance / 10
		else:
			slide_speed = 2
	sliding = true
	
	if slide_check.is.colliding():
		slide_speed += get_floor_angle() / 10
	else:
		slide_speed -= (get_floor_angle() / 5) + 0.03
	
	if slide_speed < 0:
		slide_speed = 8
		can_slide = false
		sliding = false
	
	
	velocity = slide_speed





