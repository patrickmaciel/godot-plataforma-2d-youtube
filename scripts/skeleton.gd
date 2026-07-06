extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector

enum SkeletonState {
	walk,
	dead
}

const SPEED = 30.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState
var direction = 1

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
				
	move_and_slide()
	
func walk_state(delta):
	velocity.x = SPEED * direction
	if wall_detector.is_colliding():
		# menos com menos da mais
		# Less times less equals more
		# 1 * -1 = -1 / -1 * -1 = 1
		direction *= -1
		scale.x *= -1
		
	if !ground_detector.is_colliding():
		direction *= -1
		scale.x *= -1		
		
	
func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("walk")

func dead_state(delta):
	pass
	
func go_to_dead_state():
	status = SkeletonState.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

func take_damage():
	go_to_dead_state()
