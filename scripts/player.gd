extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	duck,
	belly,
	fall,
	dead,
	wall,
	swim
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var right_wall_detector: RayCast2D = $RightWallDetector


@onready var reload_timer: Timer = $ReloadTimer

@export var max_speed = 120.0
@export var accelleration = 250
@export var decelleration = 400
@export var slide_deceleration = 100
@export var wall_acceleration = 40
@export var wall_jump_velocity = 240
@export var water_max_speed = 100
@export var water_aceleration = 200
@export var water_enter_speed = 150

const JUMP_VELOCITY = -300.0

var dead = false
var jump_count = 0
@export var jump_max_count = 2
var direction = 0
var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	

	match status:
		PlayerState.idle:
			idle_state(delta)
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
		PlayerState.wall:
			wall_state(delta)
		PlayerState.swim:
			swim_state(delta)

	move_and_slide()

func swim_state(delta):
	update_direction()
	
	if direction:
		#velocity.x = water_max_speed * direction
		velocity.x = move_toward(velocity.x, water_max_speed * direction, water_aceleration * delta)
	else:
		#velocity.x = 0
		velocity.x = move_toward(velocity.x, 0, water_aceleration * delta)
	
	var vertical_direction = Input.get_axis("up", "down")
	if vertical_direction:
		#velocity.y = water_max_speed * vertical_direction
		velocity.y = move_toward(velocity.y, water_max_speed * vertical_direction, water_aceleration * delta)
	else:
		#velocity.y = 0
		velocity.y = move_toward(velocity.y, 0, water_aceleration * delta)

func go_to_swim_state():
	status = PlayerState.swim
	anim.play("swimming")
	velocity.y = min(velocity.y, water_enter_speed)
	
func wall_state(delta):
	velocity.y += wall_acceleration * delta
	
	if left_wall_detector.is_colliding():
		anim.flip_h = false # not flip
		direction = 1 # left
	elif right_wall_detector.is_colliding():
		anim.flip_h = true # flip H
		direction = -1 # right
	else:
		go_to_fall_state()
		return
	
	if is_on_floor():
		go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("up"):
		velocity.x = wall_jump_velocity * direction
		go_to_jump_state()
		return

func go_to_wall_state():
	status = PlayerState.wall
	anim.play("wall")
	velocity = Vector2.ZERO
	jump_count = 0

func dead_state(delta):
	apply_gravity(delta)
	
func idle_state(delta):
	apply_gravity(delta)
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

func duck_state(delta):
	apply_gravity(delta)
	update_direction()
	
	if Input.is_action_just_released("down"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func walk_state(delta):
	apply_gravity(delta)
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
	apply_gravity(delta)
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
	apply_gravity(delta)
	move(delta)

	if Input.is_action_just_pressed("up") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state(delta):
	apply_gravity(delta)
	move(delta)

	if Input.is_action_just_pressed("up") && can_jump():
		go_to_jump_state()
		return

	if (left_wall_detector.is_colliding() || right_wall_detector.is_colliding()) && is_on_wall():
		go_to_wall_state()
		return

	if is_on_floor():
		jump_count = 0
	if velocity.x == 0:
		go_to_idle_state()
		return
	else:
		go_to_walk_state()
		return

func go_to_dead_state():
	if status == PlayerState.dead:
		return
		
	#if !dead:
		#dead = true
	status = PlayerState.dead
	anim.play("dead")
	velocity.x = 0
	# collision_shape_2d.process_mode = Node.PROCESS_MODE_DISABLED
	# hitbox_collision_shape_2d.process_mode = Node.PROCESS_MODE_DISABLED
	reload_timer.start()
	
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

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
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
	
	hitbox_collision_shape_2d.shape.size.y = 10
	hitbox_collision_shape_2d.position.y = 3

func set_large_collider():
	collision_shape_2d.shape.radius = 8
	collision_shape_2d.shape.height = 16
	collision_shape_2d.position.y = 0

	hitbox_collision_shape_2d.shape.size.y = 15
	hitbox_collision_shape_2d.position.y = 0.5
	
# our hitbox are invaded by something OMG
func _on_hitbox_area_entered(area: Area2D) -> void:
	# Skeleton.Hitbox is in area Enemies
	# so area2D is a hitbox in the Enemies group
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area(area)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		go_to_dead_state()
		
	if body.is_in_group("Water"):
		go_to_swim_state()
	
	
func hit_enemy(area: Area2D):
	# y grow when dropping , and are negative when up up up
	if velocity.y > 0:
		# enemie die!
		# that line need a refactor, because its not validate anything, just calling
		area.get_parent().take_damage()
		go_to_jump_state()
		return
	# elif status != PlayerState.dead:
	else:
		# player die!
		go_to_dead_state()
		return

func hit_lethal_area(_area: Area2D):
	# its necessary to mark the Player.Hitbox.Collison.Mask = 5 (lethal_area)
	go_to_dead_state()

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		jump_count = 0
		go_to_jump_state()
