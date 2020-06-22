extends KinematicBody2D

func on_interact():
	print("They interact with me!")

	var bib: BlockingInputBox = get_node("/root/Main/BlockingInputBox")
	bib.ask_input()
