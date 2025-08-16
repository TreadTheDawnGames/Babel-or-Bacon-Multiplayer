extends Node2D
class_name CardValueDisplay


func SetLables(value : int):
	for lable : RichTextLabel in get_children().filter(func(a): return a is RichTextLabel):
		lable.text = CardizeNumber(value)
	return

func CardizeNumber(num : int) -> String:
	match num:
		-1: return ""
		0: return "$"
		10: return "&"
		11: return "J"
		12: return "Q"
		13: return "K"
		14: return "A"
		15: return "}"
		16: return "|"
		17: return "`"
		18: return "~"
		19: return "_"

		_: return str(num)
