extends KinematicBody2D

func on_interact():
	print("They interact with me!")
	var bdb: BlockingDialogBox = get_node("/root/Main/BlockingDialogBox")
	bdb.append_text("Hello world! (slow)\n", 90)
	bdb.append_text("I write text faster! (fast)\n", 30)
	bdb.append_text("Or just immediate\n", 0)	
	bdb.append_text("With [color=blue]colors[/color]: [color=green]lorem[/color] ipsum bla bla this is just some demo text nothing to see here.", 10)
	bdb.append_text("Ùnïçodë? Natürlich, when the fond allows that. すごい！\n", 100)
	bdb.append_text("[shake]Woooow[/shake], a [rainbow]RAINBOW[/rainbow]", 100)
	bdb.append_text("[tornado]and many[/tornado] [fade]more other effects[/fade]", 100)
