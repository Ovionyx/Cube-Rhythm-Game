extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	var vp_size = get_tree().get_root().size / 2
	if event is InputEventMouseMotion:
		var pos = event.position
		var facing = Vector3(pos.x / vp_size.x - 1, -pos.y / vp_size.y + 1, 1)
		print(facing)
		transform = transform.looking_at(facing, Vector3.UP)
