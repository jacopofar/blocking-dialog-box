extends KinematicBody2D

func on_interact():
	print("They interact with me!")
	var bdb: BlockingDialogBox = get_node("/root/Main/BlockingDialogBox")
	bdb.append_text("Hello world! (slow)\n", 90)
	bdb.append_text("I write text faster! (fast)\n", 30)
	bdb.append_text("You can go faster through a dialogue by pressing enter or clicking!\n", 30)
	bdb.append_text("But it can be [set_skip 0]prevented, ah ah ah[set_skip 300]\n", 200)
	bdb.append_text("Or even immediate\n", 0)	
	bdb.append_text("With [color=blue]colors[/color]: [color=green]lorem[/color] ipsum bla bla this is just some demo text nothing to see here.", 10)
	bdb.append_text("Ùnïçodë? Natürlich, when the font allows that. 今日は!！\n", 100)
	bdb.append_text("[shake]Woooow[/shake], a [rainbow]RAINBOW[/rainbow]", 50)
	bdb.append_text("[tornado]and many[/tornado] [fade]more other effects[/fade]", 50)
	

