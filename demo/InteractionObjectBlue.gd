extends KinematicBody2D

var bdb: BlockingDialogBox 
var bib: BlockingInputBox

func _ready():
	bdb = get_node("/root/Main/BlockingDialogBox")
	bib = get_node("/root/Main/BlockingInputBox")
	
func on_interact():
	bdb.append_text("Hello\n", 20)
	bdb.append_text("What's your name?\n[break ask_name]", 10)
	yield(bdb, "break_reached")
	ask_name()


func ask_name():
	bib.ask_input()
	var name: String = yield(bib, "text_entered")
	when_name_inserted(name)

func when_name_inserted(name: String):
	# avoid double input by closing the box instead of waiting for the break to finish
	# not strictly necessary but nice
	bdb.hide_box()
	bdb.append_text("Ah, so your name is [rainbow]" + name + "[/rainbow]", 10)
	bdb.append_text("\nNice to meet you!", 10)
