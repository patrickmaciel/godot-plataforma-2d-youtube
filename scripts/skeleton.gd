extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

enum SkeletonState {
	walk,
	dead
}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState

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
	pass
	
func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("walk")

func dead_state(delta):
	pass
	
func go_to_dead_state():
	status = SkeletonState.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED

func take_damage():
	go_to_dead_state()
