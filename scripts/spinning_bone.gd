extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# that the wrong way to do, because the speed is relative to the FPS
	# position.x += speed
	position.x += speed * delta * direction

func set_direction(skeleton_direction):
	direction = skeleton_direction
	anim.flip_h = direction < 0


# when timer expire, the object is released from the memory
func _on_self_destruct_timer_timeout() -> void:
	queue_free()

# for players
func _on_area_entered(_area: Area2D) -> void:
	queue_free()

# for terrain
func _on_body_entered(_body: Node2D) -> void:
	queue_free()
