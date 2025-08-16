extends TDCardData
class_name PlacableObject_TDCardData

@export var OBJ_SCENE : PackedScene
var object_to_spawn : PlacableObject


func _init():
	super._init("TestCard")
	return

func SpecialSetup(_card : TDCard):
	if(_card is not BoBCard):
		printerr("Trying to set up a placable object card data on a non-BoB Card")
		return
	
	object_to_spawn = OBJ_SCENE.instantiate()
	
	var card : BoBCard = _card as BoBCard
	card.background.texture = object_to_spawn.background_color_texture
	card.icon.texture = object_to_spawn.icon
	
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: SpecialSetup has not been implemented. card: " + CardName)
	return

func Frame(_card : TDCard, _delta : float) -> void:
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: Frame has not been implemented. card: " + CardName)
	return

## Called every frame while the cursor is hovered over the associated TDCard.
func WhileHovered(_card : TDCard):
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: WhileHovered has not been implemented. card: " + CardName)
	return

func HoverEnterAction(_card : TDCard) -> void:
	print("Hovered")
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: HoverEnterAction has not been implemented. card: " + card.cardName)
	return

func GrabAction(_card : TDCard) -> void:
	print("grabbed")
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it:  GrabAction has not been implemented. card: " + card.cardName)
	return

func EnterUsable(_playArea : TDCardPlayArea, _card : TDCard) -> void:
	print("enter usable")
	return

func Preplay(_playArea : TDCardPlayArea, _card : TDCard) -> void:
	print("Preplay")
	return

func PlayCard(_playArea : TDCardPlayArea, _card : TDCard) -> void:
	print("attempting to play")
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: PlayCard has not been implemented. card: " + card.cardName + " playType: " + playType)
	if(_playArea.ValidPlayType("activate")):
		print("Played card!")
		_card.get_tree().root.add_child(object_to_spawn)
		_card.queue_free()
	return

func Postplay(_playArea : TDCardPlayArea, _card : TDCard) -> void:
	return

func ExitUsable(_card : TDCard) -> void:
	return

func DropAction(_card : TDCard) -> void:
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: DropAction has not been implemented. card: " + card.cardName)
	return

func HoverExitAction(_card : TDCard) -> void:
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: HoverExitAction has not been implemented. card: " + card.cardName)
	return
