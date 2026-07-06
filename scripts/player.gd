extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	duck,
	belly
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const SPEED = 80.0
const JUMP_VELOCITY = -300.0

var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_satate()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.duck:
			duck_state()
		PlayerState.belly:
			belly_state()
	
	move_and_slide()

func idle_satate():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return
	
	if Input.is_action_just_pressed("up"):
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("down"):
		go_to_duck_state()
		return	

func duck_state():
	move()
	if Input.is_action_just_released("down"):
		exit_from_duck_state()
		go_to_idle_state()
		return
		
func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("up"):
		go_to_jump_state()
		return		
	
	if Input.is_action_just_pressed("down"):
		go_to_belly_state()
		return

func belly_state():
	move()
	if Input.is_action_just_released("down"):
		if velocity.x != 0:
			go_to_walk_state()
		elif velocity.x == 0:
			go_to_idle_state()
	
func jump_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()	
		else:
			go_to_walk_state()
	
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_duck_state():
	status = PlayerState.duck
	collision_shape_2d.shape.radius = 5
	collision_shape_2d.shape.height = 10
	collision_shape_2d.position.y = 3
	anim.play("duck")

func exit_from_duck_state():
	collision_shape_2d.shape.radius = 8
	collision_shape_2d.shape.height = 16
	collision_shape_2d.position.y = 0
	
func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_belly_state():
	status = PlayerState.belly
	anim.play("belly")
	
func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY

func move():
	update_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false	
