extends Control
var last_path

# Called when the node enters the scene tree for the first time.
func _ready():
	var file_prompt : FileDialog = %DirectoryPrompt
	file_prompt.current_dir = OS.get_user_data_dir().split("AppData/")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	size = get_parent().size

# processes when the chart path has been selected and the open button has been pressed
func _on_directory_prompt_dir_selected(dir):
	%Path.text = dir


func _on_path_button_button_down():
	var file_prompt : FileDialog = %DirectoryPrompt
	file_prompt.show()


func _on_confirm_button_down():
	var dir_acc = DirAccess.open("user://Charts")
	if dir_acc.dir_exists(%Path.text):
		$"../..".open(%Path.text)
		_on_cancel_button_down()
	else:
		%InvalidPath.show()

func _on_cancel_button_down():
	get_parent().hide()
	%InvalidPath.hide()
	%Path.text = ""
