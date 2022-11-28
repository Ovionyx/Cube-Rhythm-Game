extends MeshInstance3D
var velocity = Vector3.ZERO
var default_pos
var will_snap = false
var acceleration = 80
var stall = false
var rot

# Called when the node enters the scene tree for the first time.
func _ready():
	default_pos = position
	

func bump(vel):
	will_snap = false
	position = default_pos
	velocity = vel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stall:
		velocity = velocity.move_toward(Vector3.ZERO,delta*acceleration)
		if velocity != Vector3.ZERO:
			rot = velocity.normalized()
		rotation += rot * delta * 15
	else:
		rotation = Vector3.ZERO
		velocity += (default_pos - position).normalized() * delta * acceleration
	position += velocity * delta
	var dot = sign(velocity.dot((default_pos - position)))
	if dot == 1:
		will_snap = true
	if dot == -1 and will_snap:
		will_snap = false
		velocity = Vector3.ZERO
		position = default_pos
