extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	duck,
	belly,
	fall,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var max_speed = 120.0
@export var accelleration = 250
@export var decelleration = 80
@export var slide_deceleration = 100
const JUMP_VELOCITY = -300.0


var jump_count = 0
@export var jump_max_count = 2
var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_satate(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.belly:
			belly_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.dead:
			dead_state(delta)

	move_and_slide()

func dead_state(_delta):
	pass
	
func idle_satate(delta):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("up"):
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("down"):
		go_to_duck_state()
		return

func duck_state(_delta):
	update_direction()
	if Input.is_action_just_released("down"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func walk_state(delta):
	move(delta)
	
	if velocity.x == 0:
		go_to_idle_state()
		return

	if Input.is_action_just_pressed("up"):
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("down"):
		go_to_belly_state()
		return

	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

func belly_state(delta):
	# from what speed, and go until what speed, decrement
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	# move(delta)
	
	if Input.is_action_just_released("down"):
		exit_from_belly_state()
		go_to_walk_state()
		return

	if velocity.x == 0:
		exit_from_belly_state()
		go_to_duck_state()
		return

func jump_state(delta):
	move(delta)

	if Input.is_action_just_pressed("up") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state(delta):
	move(delta)

	if Input.is_action_just_pressed("up") && can_jump():
		go_to_jump_state()
		return

	if is_on_floor():
		jump_count = 0
	if velocity.x == 0:
		go_to_idle_state()
	else:
		go_to_walk_state()

func go_to_dead_state():
	velocity = Vector2.ZERO
	status = PlayerState.dead
	anim.play("dead")
	
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_duck_state():
	status = PlayerState.duck
	set_small_collider()
	anim.play("duck")

func exit_from_duck_state():
	set_large_collider()

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_belly_state():
	status = PlayerState.belly
	anim.play("belly")
	set_small_collider()

func exit_from_belly_state():
	set_large_collider()

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func move(delta):
	update_direction()

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, accelleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, decelleration * delta)

func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func can_jump() -> bool:
	return jump_count < jump_max_count

func set_small_collider():
	collision_shape_2d.shape.radius = 5
	collision_shape_2d.shape.height = 10
	collision_shape_2d.position.y = 3

func set_large_collider():
	collision_shape_2d.shape.radius = 8
	collision_shape_2d.shape.height = 16
	collision_shape_2d.position.y = 0


# our hitbox are invaded by something OMG
func _on_hitbox_area_entered(area: Area2D) -> void:
	# y grow when dropping , and are negative when up up up
	if velocity.y > 0:
		# enemie die!
		area.get_parent().queue_free()
		go_to_jump_state()
	else:
		go_to_dead_state()
	
