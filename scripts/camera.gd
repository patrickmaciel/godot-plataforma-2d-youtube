extends Camera2D

# camera has a goal, a target, that is THE PLAYER
var target: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_target()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# position = camera position
	position = target.position

func get_target():
	# when load I need to get the player from group
	var nodes = get_tree().get_nodes_in_group("Player")
	# get_tree().get_first_node_in_group("Player")
	if nodes.size() == 0:
		push_error("Player not found")
		return
	
	target = nodes[0]
