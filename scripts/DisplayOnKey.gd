extends GPUParticles3D
@export var key : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	emitting = Input.is_key_pressed(key)
