extends Node3D
var vel = PI/2

var lifetime = 1
var dying = false

func hit():
	$a/particles.emitting = false
	$b/particles.emitting = false
	dying = true
	$a/mesh.hide()
	$b/mesh.hide()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$a/particles.emitting = true
	$b/particles.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dying:
		lifetime -= delta
		if lifetime <= 0:
			queue_free()
	$a.rotation.y += vel * delta
	$b.rotation.y += vel * delta
	if $a.rotation.y >= PI:
		queue_free()
