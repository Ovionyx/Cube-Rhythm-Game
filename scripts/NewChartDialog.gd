extends Control
var last_path

# Called when the node enters the scene tree for the first time.
func _ready():
	var file_prompt : FileDialog = %AudioFilePrompt
	file_prompt.add_filter("*.mp3", "MP3 Files")
	file_prompt.current_dir = OS.get_user_data_dir().split("AppData/")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	size = get_parent().size
		
# processes when the audio file path has been selected and the open button has been pressed
func _on_audio_file_prompt_file_selected(path):
	%AudioPath.text = path

# opens the file prompt to select the audio file
func _on_audio_button_button_down():
	var file_prompt : FileDialog = %AudioFilePrompt
	file_prompt.show()

# creates a new chart
func _on_confirm_button_down():
	var dir : DirAccess = DirAccess.open("user://Charts/")
	dir.make_dir(%Artist.text + " - " + %Title.text)
	dir.copy(%AudioPath.text, "user://Charts/" + %Artist.text + " - " + %Title.text + "/audio.mp3")
	if !dir.file_exists("chart.rhythmos"):
		var file : FileAccess = FileAccess.open("user://Charts/" + %Artist.text + " - " + %Title.text + "/chart.rhythmos", FileAccess.WRITE)
		file.store_line("120")
	$"../..".open("user://Charts/" + %Artist.text + " - " + %Title.text)
	_on_cancel_pressed()

#hides prompt and reset fields
func _on_cancel_pressed():
	get_parent().hide()
	%Title.text = ""
	%Artist.text = ""
	%AudioPath.text = ""
