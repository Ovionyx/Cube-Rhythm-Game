extends Node3D
var color
@onready var base_color = color #the color the note was set as
var color_update #checks for updates in the color note
var length = 1 #length of the note
var vel = 9 #velocity of the note
var struck = false #if the note has been hit

var lifetime = 1 #how much longer the instance will exist to allow particles to finish
var dying = false #whether lifetime should decrease

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
	color_update = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if struck:
		color = base_color
	if color != color_update:
		var material = $mesh.material_override.duplicate(true)
		material.albedo_color = color
		material.emission = color
		$mesh.material_override = material
		color_update = color
	$mesh.scale.z = max(length,0) * vel
	$mesh.position.z = min(-length,0) * vel / 2
	if abs(position.x) < 0.25 or abs(position.z) < 0.25:
		if !struck:
			color = Color(0.1,0.1,0.1)
		length -= delta
		if length <= -1:
			queue_free()
	else:
		position += transform.basis.z * vel * delta
