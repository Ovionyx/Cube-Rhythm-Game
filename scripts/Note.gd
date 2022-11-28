extends Node3D
var color
var vel = 9 #velocity of the note
var lifetime = 1 #how much longer the instance will exist to allow particles to finish
var dying = false #whether lifetime should decrease
var missed = false #if the note has passed and was missed
var age = 0 #how long the note has existed
@onready var color_update = color #checks for updates in the color note

#processes being hit
func hit():
	$particles.emitting = false
	dying = true
	$mesh.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var material = $mesh.material_override.duplicate(true)
	material.albedo_color = color
	material.emission = color
	$mesh.material_override = material
	$particles.material_override = material
	$particles.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	age += delta
	if age >= 9/vel:
		color = Color(0.5, 0.5, 0.5)
		
	if age > 18/vel and !dying:
		hit()
		
	if color != color_update:
		var material = $mesh.material_override.duplicate(true)
		material.albedo_color = color
		material.emission = color
		$mesh.material_override = material
		color_update = color
	
	if dying:
		lifetime -= delta
		if lifetime <= 0:
			queue_free()
	position += transform.basis.z * vel * delta
		
