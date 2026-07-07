extends AnimatableBody2D

@onready var target: Sprite2D = $Target

@export var time = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target.visible = false
	
	# tween interpolate between positions
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	# to where - target sprite2D
	tween.tween_property(self, "global_position", target.global_position, time)
	# back to here - back to the main position
	tween.tween_property(self, "global_position", global_position, time)
	tween.set_loops()
