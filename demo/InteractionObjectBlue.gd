extends KinematicBody2D

var bdb: BlockingDialogBox 
var bib: BlockingInputBox

func _ready():
	bdb = get_node("/root/Main/BlockingDialogBox")
	bib = get_node("/root/Main/BlockingInputBox")
	
func on_interact():
	bdb.append_text("Hello\n", 20)
	bdb.append_text("What's your name?\n[break ask_name]", 10)
	bdb.connect("break_reached", self, "ask_name")	

func ask_name(_unused: String):
	bib.ask_input()
	bib.connect("text_entered", self, "when_name_inserted")	

func when_name_inserted(name: String):
	bdb.append_text("Ah, so your name is [rainbow]" + name + "[/rainbow]", 10)
	bdb.append_text("\nNice to meet you!", 10)
