extends Node3D
var time_begin #time (in microseconds) after the start of the chart
var time_delay #the delay of the audio server

var end_delay = 3
var ending = false

@export var autoplay : bool

var editor : PackedScene = load("res://scenes/editor.tscn") #the editor scene. return here after chart ends

var BPM : float #Beats per minute. Retreived from chart file
var SPB : float #Seconds per beat. equivalent to 60/BPM
var current_beat = 0 #Used for checking when a beat has passed for debugging. Likely will be removed
var chart = [] #the data of the chart. format: [type, key, timestamp, (held) duration]
var active_notes = [] #any notes that have been instantiated and are in the scene. format: [node, type, key, timestamp, (held) duration]
var held_notes = [] #held notes that are currently being pressed. format: [node, type, key, timestamp, (held) duration]

var chart_path = "user://Charts/Toby Fox - ASGORE" #Path of the chart folder. Contains audio.mp3 and chart.rhythmos

var time = 0 #playback position of the song

var score = 0

#scenes for instantiating notes
@onready var NOTE : PackedScene = load("res://scenes/note.tscn")
@onready var HELDNOTE : PackedScene = load("res://scenes/held_note.tscn")
@onready var SPINNOTE : PackedScene = load("res://scenes/spin_note.tscn")

#dictionary linking the note key to a keycode
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

#dictionary containing most information relating to notes, such as spawn positition and rotation, color, and the objects and velocity to "bump" 
@onready var note_pos : Dictionary = {
	"h" = [Vector3(0,0.5,0),     Vector3(0,0,0), 0, 0, 0, Vector3(0,-2,0)],
	"g" = [Vector3(0,0.5,0),     Vector3(PI,0,0), 0, 0, 0, Vector3(0,2,0)],
	"j" = [Vector3(9,0.5,-0.5),  Vector3(0,-PI/2,0), Color(0,0.75,1),  [$%FT,$%FTL,$%FTR], Vector3(-1,0,0), Vector3(0,-1,-1)],
	"f" = [Vector3(-9,0.5,-0.5), Vector3(0,PI/2,0),  Color(0,0.75,1),  [$%FT,$%FTL,$%FTR], Vector3(1,0,0),  Vector3(0,1,1)],
	"s" = [Vector3(-9,0.5,0.5),  Vector3(0,PI/2,0),  Color(0,1,0),     [$%FD,$%FDL,$%FDR], Vector3(1,0,0),  Vector3(0,-1,1)],
	"l" = [Vector3(9,0.5,0.5),   Vector3(0,-PI/2,0), Color(0,1,0),     [$%FD,$%FDL,$%FDR], Vector3(-1,0,0), Vector3(0,1,-1)],
	"k" = [Vector3(0.5,0.5,9),   Vector3(0,PI,0),    Color(1,0,0.5),   [$%FR,$%FDR,$%FTR], Vector3(0,0,-1), Vector3(1,1,0)],
	"i" = [Vector3(0.5,0.5,-9),  Vector3(0,0,0),     Color(1,0,0.5),   [$%FR,$%FDR,$%FTR], Vector3(0,0,1),  Vector3(1,1,0)],
	"e" = [Vector3(-0.5,0.5,-9), Vector3(0,0,0),     Color(1,0.5,0),   [$%FL,$%FDL,$%FTL], Vector3(0,0,1),  Vector3(1,1,0)],
	"d" = [Vector3(-0.5,0.5,9),  Vector3(0,PI,0),    Color(1,0.5,0),   [$%FL,$%FDL,$%FTL], Vector3(0,0,-1), Vector3(1,1,0)],
}

#instantiate new note with chart data into the scene and append a pointer to active_notes
func spawn_note(note):
	if note[0] == "note":
		if note[1] != "g" and note[1] != "h":
			var obj : Node3D = NOTE.instantiate()
			obj.color = note_pos[note[1]][2]
			obj.position = note_pos[note[1]][0]
			obj.rotation = note_pos[note[1]][1]
			add_child(obj)
			return(obj)
		else:
			var obj : Node3D = SPINNOTE.instantiate()
			obj.position = note_pos[note[1]][0]
			obj.rotation = note_pos[note[1]][1]
			add_child(obj)
			return(obj)
	elif note[0] == "held":
		if note[1] != "g" and note[1] != "h":
			var obj : Node3D = HELDNOTE.instantiate()
			obj.color = note_pos[note[1]][2]
			add_child(obj)
			obj.length = SPB * note[3].to_float()
			obj.position = note_pos[note[1]][0]
			obj.rotation = note_pos[note[1]][1]
			return(obj)

#processes the note being hit
func hit_note(note):
	if note[1] == "note": #check if note is a normal note
		score += (0.2 - abs(note[3].to_float()*SPB - time))*2000
		#increment score
		$HUD/Score.text = str(int(score))
		$HUD/Score.scale = Vector2(1.5,1.5)
		note[0].hit() #tell the note its been hit
		active_notes.erase(note) #remove the note from active notes
		if note[2] != "g" and note[2] != "h": #check for spin notes (they're weird)
			#display animation
			for cube in note_pos[note[2]][3]:
				print(cube.get_script().get_script_method_list())
				cube.bump(note_pos[note[2]][4] * 8)
		$CameraPivot.velocity += note_pos[note[2]][5]
				
	elif note[1] == "held": #check if note is a held note
		#add the note data to held_notes and remove it from active_notes
		held_notes.append(note + [(time/SPB+note[4].to_float())])
		active_notes.erase(note)
		#tell the note it has been hit
		note[0].struck = true
		#display animation
		for cube in note_pos[note[2]][3]:
			cube.velocity = (note_pos[note[2]][4] * 8)
			cube.stall = true
		$CameraPivot.velocity += note_pos[note[2]][5]
		
#called when the game starts
func _ready():
	
	print($CameraPivot.rotation)
	
	$CameraPivot/Camera3D.attributes.exposure_multiplier = 1
	#load the charts song and tell the AudioStreamPlayer to play it
	var mp3 = AudioStreamMP3.new()
	var file = FileAccess.open(chart_path + "/audio.mp3", FileAccess.READ)
	mp3.data = file.get_buffer(file.get_length())
	$Player.stream = mp3
	#load chart data into chart
	file = FileAccess.open(chart_path + "/chart.rhythmos", FileAccess.READ)
	while not(file.eof_reached()):
		var line = file.get_line()
		
		if line != "":
			chart += [line.rsplit(" ", false)]
	print(chart)
	BPM = chart[0][0].to_float()
	chart.pop_front()
	SPB = 60/BPM
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()


func _process(delta):
	# Example code from godot documentation
	# Obtain from ticks.
	time = (Time.get_ticks_usec() - time_begin) / 1000000.0 - 3
	# Compensate for latency.
	time -= time_delay
	
	$Keybinds.scale = Vector3.ONE * clamp( -pow(time + 1, 3) + 1, 0, 1)
	
	#start playback of the song at the proper time
	if time + time_delay >= 0 and !$Player.playing:
		$Player.play()
		
	#instantiate notes at the proper time
	if chart.size() > 0 and (time+1)/SPB >= chart[0][2].to_float():
		
		active_notes.append([spawn_note(chart[0])] + Array(chart[0]))
		chart.pop_front()
	
	#progress scorebar animation
	$HUD/Score.scale -= ($HUD/Score.scale - Vector2(1,1))/10
	
	#debug for checking for sync
	if int(time/SPB) != current_beat:
		print(int(time/SPB))
		current_beat = int(time/SPB)
	
	#checks to make sure the note hasn't been freed previously. If it is, it is removed from active_notes
	for note in active_notes:
		if !is_instance_valid(note[0]):
			active_notes.erase(note)
	
	#process held notes
	for note in held_notes:
		#increment score
		if note[3].to_float() <= time/SPB:
			score += 1000 * delta
			$HUD/Score.text = str(int(score))
			$HUD/Score.scale = Vector2(1.5,1.5)
			$CameraPivot.velocity += note_pos[note[2]][5] * delta * 1
		#take care of the note after its end has been reached
		if note[3].to_float()+note[4].to_float() <= time/SPB:
			held_notes.erase(note)
			note[0].queue_free()
			for cube in note_pos[note[2]][3]:
				cube.stall = false
	
	#if no notes are left, start ending sequence
	if chart.size() == 0 and active_notes.size() == 0 and held_notes.size() == 0:
		ending = true
		
	#progress ending sequence
	if ending:
		$Player.volume_db = (end_delay - 3) * 10
		$CameraPivot/Camera3D.attributes.exposure_multiplier = end_delay / 3
		end_delay -= delta
	
	#switch to scene after ending sequence
	if end_delay <= 0:
		var editor_node = editor.instantiate()
		var tree = get_tree().root
		tree.remove_child(self)
		tree.add_child(editor_node)
		editor_node.open(chart_path)
		
#process inputs
func _input(event):
	if event is InputEventKey and !event.pressed:
		#processes an early release of a held note
		for note in held_notes:
			held_notes.erase(note)
			note[0].color = Color(0.1,0.1,0.1)
			for cube in note_pos[note[2]][3]:
				cube.stall = false
	elif event is InputEventKey and !event.echo:
		#process the input to hit a note, calling the hit_note function
		for note in active_notes:
			if abs(note[3].to_float()*SPB - time) <= 0.5:
				if note_keybinds[note[2]] == event.keycode:
					hit_note(note)
					break
	
		
