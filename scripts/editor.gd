extends Control

var start_anim = 0.0

var chart = [] #the data of the chart. format: [type, key, timestamp, (held) duration]
var BPM #Seconds per beat. equivalent to 60/BPM
var SPB #Beats per minute. Retreived from chart file
var length_in_beats #length of the song, in beats
var notes = [] #notes that are displayed in the editor. format: [node : ColorRect, type, key, timestamp, (held) duration]
var grab = [null, 0] #dictates what note is being grabbed, and in what way it is being grabbed (0: whole note, 1: start of held note, 2: end of held note)
var current_path #path of the chart thats being edited

var saved = true #indicates if the file has no unsaved changes

var playing = false #indicates if the song has been playing
var playback_pos = 0 #position of the audio playback and position slider

var game : PackedScene = load("res://scenes/game.tscn") #game scene. loaded when the run option is selected

#pairs note keys to keycodes
var note_keybinds : Dictionary = {
	"h" = KEY_H,
	"g" = KEY_G,
	"j" = KEY_J,
	"f" = KEY_F,
	"s" = KEY_S,
	"l" = KEY_L,
	"k" = KEY_K,
	"i" = KEY_I,
	"e" = KEY_E,
	"d" = KEY_D,
}

#contains display information for notes in the editor
var note_dict = {
	"g" = [0.05, Color("ffbf00")],
	"h" = [0.15, Color("ffbf00")],
	"f" = [0.25, Color("007fff")],
	"j" = [0.35, Color("007fff")],
	"s" = [0.45, Color("00ff3f")],
	"l" = [0.55, Color("00ff3f")],
	"i" = [0.65, Color("ff003f")],
	"k" = [0.75, Color("ff003f")],
	"e" = [0.85, Color("ff7f00")],
	"d" = [0.95, Color("ff7f00")],
}

#creates an object to represent the note with the passed data. appends object and note data to notes
func create_note(note):
	if Array(note) == [""] or Array(note) == []:
		return
	var color_rect : ColorRect = ColorRect.new()
	color_rect.offset_left = -5
	color_rect.offset_right = 5
	color_rect.anchor_left = note[2].to_float()/length_in_beats
	color_rect.anchor_top = note_dict[note[1]][0]
	color_rect.anchor_bottom = color_rect.anchor_top
	color_rect.color = note_dict[note[1]][1]
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if note[0] == "note":
		color_rect.offset_top = -%StaffPanel.size.y / 20 + 2
		color_rect.offset_bottom = %StaffPanel.size.y / 20 - 2
		color_rect.anchor_right = color_rect.anchor_left
		
	elif note[0] == "held":
		color_rect.offset_top = -%StaffPanel.size.y / 20 + 10
		color_rect.offset_bottom = %StaffPanel.size.y / 20 - 10
		color_rect.anchor_right = color_rect.anchor_left + note[3].to_float()/length_in_beats
		
	%StaffPanel.add_child(color_rect)
	notes.append([color_rect]+Array(note))

#plays an audio file from a path. modified code from unknown source
func play_external_file(path):
	var mp3 = AudioStreamMP3.new()
	var file
	file = FileAccess.open(path + "/audio.mp3", FileAccess.READ)
	mp3.data = file.get_buffer(file.get_length())
	$AudioStreamPlayer.stream = mp3

#function that sorts the notes so they are in the right order in the file
func sort_notes(a, b):
	if a[3].to_float() < b[3].to_float():
		return true
	return false

#load a chart from the provided path
func open(path : String):
	saved = true
	current_path = path
	chart = []
	for note in notes:
		note[0].queue_free()
	notes = []
	play_external_file(path)
	#var dir = DirAccess.open(path)
	var file = FileAccess.open(path + "/chart.rhythmos", FileAccess.READ)
	while not(file.eof_reached()):
		chart += [file.get_line().rsplit(" ", false)]
	print(chart)
	if Array(chart[0]) == []:
		chart = [["120"]]
	BPM = chart[0][0].to_float()
	chart.pop_front()
	%BPMField.text = str(BPM)
	SPB = 60/BPM
	length_in_beats = $AudioStreamPlayer.stream.get_length() / SPB
	%StaffScroll.max_value = length_in_beats
	
	for note in chart:
		create_note(note)
		
	$MainPanel/MainVBox/EditorVBox.show()
	staff_update()

#saves the chart to current_path
func save():
	saved = true
	var file : FileAccess = FileAccess.open(current_path + "/chart.rhythmos", FileAccess.WRITE)
	file.store_line(str(BPM))
	notes.sort_custom(sort_notes)
	for note in notes:
		var line = ""
		for value in note:
			if value is String:
				line += value + " "
		file.store_line(line.lstrip(" "))
	file.flush()

#update the displaying of the staff
func staff_update():
	%Ruler.queue_redraw()
	%StaffPanel.offset_left = -%StaffScroll.value / %StaffScroll.page*%Base.size.x
	%StaffPanel.offset_right = %StaffPanel.offset_left + (%StaffScroll.max_value/%StaffScroll.page*%Base.size.x)
	%StaffPanel.queue_redraw()


#called when the editor starts
func _ready():
	$MainPanel/MainVBox/EditorVBox.hide()
	open("user://Charts/Toby Fox - ASGORE")
	preload("res://assets/pause.svg")
	preload("res://assets/play.svg")
	
	$MainPanel.modulate = Color(1, 1, 1, 0)
	$ColorRect.color = Color(0, 0, 0, 1)

#called every frame
func _process(delta):
	if playing:
		playback_pos = $AudioStreamPlayer.get_playback_position()
		%StaffScroll.value = playback_pos / SPB - %StaffScroll.page / 2
		%StaffPanel.queue_redraw()
		
	if start_anim < 1.0:
		print(start_anim)
		start_anim = min(start_anim + delta, 1)
		$MainPanel.modulate = Color(1, 1, 1, start_anim)
		$ColorRect.color = Color(0, 0, 0, 1 - start_anim)

#process keyboard shortcuts
func _input(event):
	if event is InputEventKey and event.is_pressed() and !event.is_echo():
		if event.ctrl_pressed:
			if event.keycode == KEY_N:
				_on_file_index_pressed(0)
			elif event.keycode == KEY_O:
				_on_file_index_pressed(1)
			elif event.keycode == KEY_S:
				save()
		else:
			if event.keycode == KEY_F5:
				_on_file_index_pressed(3)
			if playing and event.keycode in note_keybinds.values():
				var type
				if event.shift_pressed:
					type = "held"
				else:
					type = "note"
					
				create_note([type, note_keybinds.find_key(event.keycode), str( round(playback_pos / SPB * 4) / 4 )])
			

#processes selected menu options from the "file" menu
func _on_file_index_pressed(index):
	if index == 0: #"New"
		$NewChartDialog.show()
	elif index == 1: #"Open"
		$OpenChartDialog.show()
	elif index == 2: #"Save"
		save()
	elif index == 3: #"Run"
		save()
		var game_node = game.instantiate()
		game_node.chart_path = current_path
		var tree = get_tree().root
		tree.remove_child(self)
		tree.add_child(game_node)

#processes editor events
func _on_staff_panel_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		#zoom in and out
		if event.button_index == 4:
			%StaffScroll.page /= 1.1
			staff_update()
		elif event.button_index == 5:
			%StaffScroll.page *= 1.1
			staff_update()
			
		#processes left click
		elif event.button_index == 1:
			var pos = event.position
			for note in notes:
				var rect : Rect2 = Rect2(note[0].position,note[0].size)
				if rect.has_point(pos): #allow the user to move and adjust notes
					print("clicked: ", note)
					if note[1] == "note":
						grab = [note, 0]
					if note[1] == "held":
						if pos.x < note[0].position.x + 10:
							print("Grab Start of ", note)
							grab = [note, 1]
						elif pos.x > note[0].position.x + note[0].size.x - 10:
							print("Grab End of ", note)
							grab = [note, 2]
						else:
							grab = [note, 0, pos.x - note[0].position.x]
							print(grab)
					return
			#if click check failed
			if Input.is_key_pressed(KEY_SHIFT): #create held note
				create_note(["held", note_dict.keys()[floor(pos.y/%StaffPanel.size.y*10)], str( round(event.position.x / %StaffPanel.size.x * length_in_beats * 4) / 4 ), "1"])
				saved = false
			else: #create note
				create_note(["note", note_dict.keys()[floor(pos.y/%StaffPanel.size.y*10)], str( round(event.position.x / %StaffPanel.size.x * length_in_beats * 4) / 4 )])
				saved = false
		
		#processes right clicks
		elif event.button_index == 2:
			var pos = event.position
			
			for note in notes:
				var rect : Rect2 = Rect2(note[0].position,note[0].size)
				if rect.has_point(pos): #delete clicked note
					print("clicked: ", note)
					note[0].queue_free()
					notes.erase(note)
					saved = false
					break
					
	#processes moving the grabbed note
	if event is InputEventMouseMotion:
		if grab[0]:
			saved = false
			var note = grab[0]
			if grab[1] == 0:
				if note[1] == "note":
					note[3] = str( round(event.position.x / %StaffPanel.size.x * length_in_beats * 4) / 4 )
					note[0].anchor_left = note[3].to_float()/length_in_beats
					note[0].anchor_right = note[0].anchor_left
				elif note[1] == "held":
					note[3] = str( round((event.position.x - grab[2]) / %StaffPanel.size.x * length_in_beats * 4) / 4 )
					note[0].anchor_left = note[3].to_float()/length_in_beats
					note[0].anchor_right = note[0].anchor_left + note[4].to_float()/length_in_beats
			elif grab[1] == 1:
				var note_end = note[3].to_float() + note[4].to_float()
				note[3] = str( round(event.position.x / %StaffPanel.size.x * length_in_beats * 4) / 4 )
				note[4] = str( note_end - note[3].to_float())
				note[0].anchor_left = note[3].to_float()/length_in_beats
			elif grab[1] == 2:
				note[4] = str( round(event.position.x / %StaffPanel.size.x * length_in_beats * 4) / 4 - note[3].to_float() )
				note[0].anchor_right = note[0].anchor_left + note[4].to_float()/length_in_beats
	
	#releases the note
	if event is InputEventMouseButton and !event.pressed:
		if event.button_index == 1:
			grab[0] = null

#updates staff when scrolled
func _on_staff_scroll_value_changed(_value):
	staff_update()

#updates BPM and relevant info.
func _on_bpm_field_text_submitted(new_text):
	BPM = new_text.to_float()
	%BPMField.text = str(BPM)
	SPB = 60/BPM
	length_in_beats =$AudioStreamPlayer.stream.get_length() / SPB
	%StaffScroll.max_value = length_in_beats
	staff_update()
	for note in notes:
		note[0].anchor_left = note[3].to_float()/length_in_beats
		
		if note[1] == "note":
			note[0].anchor_right = note[0].anchor_left
		elif note[1] == "held":
			note[0].anchor_right = note[0].anchor_left + note[4].to_float()/length_in_beats

#start playing audio from the start of the track
func _on_replay_button_pressed():
	playback_pos = 0
	%PlayButton.button_pressed = true

#start playing audio from 4 beats earlier
func _on_play_early_button_pressed():
	playback_pos = max(playback_pos - 4 * SPB, 0)
	%PlayButton.button_pressed = true

#toggles playback of audio
func _on_play_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.play(playback_pos)
		playing = true
		%PlayButton.icon = load("res://assets/pause.svg")
	else:
		$AudioStreamPlayer.stop()
		playing = false
		%PlayButton.icon = load("res://assets/play.svg")



func _on_ruler_gui_input(event):
	print(event)
	if event is InputEventMouseButton and event.pressed or event is InputEventMouseMotion and event.button_mask > 0:
		var pos = event.position
		var beat = pos.x/%Ruler.size.x * %StaffScroll.page + %StaffScroll.value
		playback_pos = round(beat * 4) / 4 * SPB
		staff_update()
