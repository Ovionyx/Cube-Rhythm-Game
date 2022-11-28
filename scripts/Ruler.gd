extends Control

func _draw():
	var width = %StaffScroll.page
	var start = %StaffScroll.value
	for i in range(width+1):
		var j = i + int(start)
		var x = (i-fmod(start,1))*size.x/width
		var height
		if fmod(j,4) == 0:
			height = size.y
			draw_string(get_theme_default_font(),Vector2(x+5,size.y),str(j))
		else:
			height = size.y/2
		draw_line(Vector2(x,0),Vector2(x,height),Color.WHITE)
		
