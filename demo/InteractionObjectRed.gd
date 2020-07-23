extends KinematicBody2D

var bdb: BlockingDialogBox

func _ready():
	bdb = get_node("/root/Main/BlockingDialogBox")

func on_interact():
	for i in range(7):
		bdb.append_text("text line %d\n" %i, 10)
	bdb.append_text("wait for input and rotate[break clockwise]\n", 10)
	var direction: String = yield(bdb, "break_ended")
	rotate_me(direction)
	bdb.append_text("wait for input and rotate back[break counterclockwise]\n", 10)
	direction = yield(bdb, "break_ended")
	rotate_me(direction)
	
	for i in range(6):
		bdb.append_text("text line %d\n" %i, 10)
	
func rotate_me(direction: String):
	print("ROTATION: ", direction)
	if direction == "clockwise":
		$AnimationPlayer.play("rotate")
	if direction == "counterclockwise":	
		$AnimationPlayer.play_backwards("rotate")

	
