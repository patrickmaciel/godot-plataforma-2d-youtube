extends CharacterBody2D

const SPINNING_BONE = preload("uid://bnk6d6t5x8n7r")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

enum SkeletonState {
	walk,
	attack,
	dead,
}

const SPEED = 7.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState
var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.dead:
			dead_state(delta)
		SkeletonState.attack:
			attack_state(delta)
				
	move_and_slide()
	
func attack_state(_delta):
	# doing that way generate an error 
	# because of the FPS, skeleton is throwing a lot bones in the same frame
	if anim.frame == 2 && can_throw:
		throw_bone()
		can_throw = false
	
func go_to_attack_state():
	status = SkeletonState.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	
func walk_state(_delta):
	if anim.frame == 3 || anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		# menos com menos da mais
		# Less times less equals more
		# 1 * -1 = -1 / -1 * -1 = 1
		direction *= -1
		scale.x *= -1
		
	if !ground_detector.is_colliding():
		direction *= -1
		scale.x *= -1		
		
	if player_detector.is_colliding():
		go_to_attack_state()
		return
		
func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("walk")

func dead_state(_delta):
	pass
	
func go_to_dead_state():
	status = SkeletonState.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

func take_damage():
	go_to_dead_state()

func throw_bone():
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	# global position is the position relativa of the skeleton in the scene
	# but .position only, is the position relative of the skeleton scene
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
		return
