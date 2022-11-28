extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	size = get_parent().size


func _on_save_changes_dialog_close_requested():
	_on_cancel_pressed()


func _on_cancel_pressed():
	get_parent().hide()
	get_parent().set_meta("return", 0)


func _on_dont_save_pressed():
	get_parent().hide()
	get_parent().set_meta("return", 1)


func _on_save_pressed():
	get_parent().hide()
	get_parent().set_meta("return", 2)
