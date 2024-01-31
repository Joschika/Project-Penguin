extends CharacterBody3D

@export var MoveVelocity : float = 4.5
@export var SprintVelocity : float = 8.5
@export var JumpVelocity : float = 5.0

@export var LookSens : Vector2 = Vector2(0.1, 0.1)

@export var Gravity : float = 10

@export var Acceleration : float = 10
@export var Decceleration : float = 25
@export var LookAngle : Array = [-75, 85]


@export_group("Nodes")
@onready var Camera = $head/Camera3D
@onready var Head = $head
@onready var anim_player = $AnimationPlayer


var LookDir : Vector3 = Vector3.ZERO

var InputDir : Vector2 = Vector2.ZERO
var MoveDir : Vector3 = Vector3.ZERO

var FinalMoveVelocity : float = 0.0

var Sprinting : bool = false

func _ready() -> void:
	# Locks Mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _unhandled_input(event):
	
	# Look
	if event is InputEventMouseMotion:
		LookDir.x -= event.relative.x * LookSens.x
		LookDir.y = clamp(LookDir.y - event.relative.y * LookSens.y, LookAngle[0], LookAngle[1])
	if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot":
		play_shoot_effects()

func _process(delta: float) -> void:
	# Applies LookDir
	rotation_degrees.y = LookDir.x
	Head.rotation_degrees.x = LookDir.y

func _physics_process(delta: float) -> void:
	InputDir = Input.get_vector('left', 'right', 'up', 'down')
	
	MoveDir = transform.basis * Vector3(InputDir.x, 0, InputDir.y).normalized()
	
	
	# Gravity
	if not is_on_floor():
		velocity.y -= Gravity * delta
	
	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JumpVelocity
	
	# Sprint
	if Input.is_action_just_pressed('Sprint'):
		if not Sprinting:
			Sprinting = true
		else:
			Sprinting = false
	
	if Sprinting:
		FinalMoveVelocity = SprintVelocity
	else:
		FinalMoveVelocity = MoveVelocity
	
	
	# Move
	if MoveDir.length() > 0:
		velocity.x = lerp(velocity.x, MoveDir.x * FinalMoveVelocity, delta * Acceleration)
		velocity.z = lerp(velocity.z, MoveDir.z * FinalMoveVelocity, delta * Acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * Decceleration)
		velocity.z = lerp(velocity.z, 0.0, delta * Decceleration)
	
#animations
	if anim_player.current_animation == "shoot":
		pass

	elif InputDir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")
	
	move_and_slide()
	
	
	
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")

