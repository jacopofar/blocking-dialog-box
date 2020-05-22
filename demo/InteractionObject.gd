extends KinematicBody2D

func on_interact():
	print("They interact with me!")
	var bdb: BlockingDialogBox = get_node("/root/Main/BlockingDialogBox")
	bdb.append_text("Hello world! (slow)\n", 90)
	bdb.append_text("Hello world! (fast)\n", 30)
	bdb.append_text("Hello world!(immediate)\n", 0)	
	bdb.append_text("[color=blue]lorem[/color] ipsum", 100)
	bdb.append_text("\n", 100)
	bdb.append_text("[shake]Shakeee[/shake] and [rainbow] RAINBOW[/rainbow]", 100)
	bdb.append_text("[tornado]and many[/tornado][fade]more other effects[/fade]", 100)
