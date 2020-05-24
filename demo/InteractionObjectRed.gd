extends KinematicBody2D

func on_interact():
	var bdb: BlockingDialogBox = get_node("/root/Main/BlockingDialogBox")
	for i in range(7):
		bdb.append_text("text line %d\n" %i, 10)
	bdb.connect("break_ended", self, "rotate_me")	
	bdb.append_text("wait for input and rotate[break clockwise]\n", 10)
	bdb.append_text("wait for input and rotate back[break counterclockwise]\n", 10)
	
	for i in range(6):
		bdb.append_text("text line %d\n" %i, 10)
	

func rotate_me(direction: String):
	print("ROTATION: ", direction)
	if direction == "clockwise":
		$AnimationPlayer.play("rotate")
	if direction == "counterclockwise":	
		$AnimationPlayer.play_backwards("rotate")
	
