extends Panel

@onready var root : Control = $"../../../../../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	for i in range(1,10):
		draw_line(Vector2(0,i*size.y/10),Vector2(size.x,i*size.y/10),Color.DARK_GRAY)
	for i in range(1,root.length_in_beats):
		var col : Color
		if i % 4 == 0:
			col = Color.WHITE
		else:
			col = Color.DARK_GRAY
		draw_line(Vector2(i*size.x/root.length_in_beats,0),Vector2(i*size.x/root.length_in_beats,size.y),col)
	
	var pb_pos = root.playback_pos
	var x = pb_pos / root.SPB * size.x / root.length_in_beats
	print(x)
	draw_line(Vector2(x,0),Vector2(x,size.y),Color.CORNFLOWER_BLUE)
	
	
	
