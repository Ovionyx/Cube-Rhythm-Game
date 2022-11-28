@tool

extends Node3D
@export var velocity : Vector3 = Vector3.ZERO
@export var accel = 10
@export var active : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		var in_vel = velocity.abs()
		
		if pow(in_vel.x,2) + 2 * -accel * abs(rotation.x) >= 0:
			velocity.x = move_toward(velocity.x, 0, delta * accel)
		else:
			velocity.x += -sign(rotation.x)*delta*accel
		
		if pow(in_vel.y,2) + 2 * -accel * abs(rotation.y) >= 0:
			velocity.y = move_toward(velocity.y, 0, delta * accel)
		else:
			velocity.y += -sign(rotation.y)*delta*accel
			
		if pow(in_vel.z,2) + 2 * -accel * abs(rotation.z) >= 0:
			velocity.z = move_toward(velocity.z, 0, delta * accel)
		else:
			velocity.z += -sign(rotation.z)*delta*accel
			
		velocity *= 1 - 0 * delta
		rotation += velocity * delta
	
