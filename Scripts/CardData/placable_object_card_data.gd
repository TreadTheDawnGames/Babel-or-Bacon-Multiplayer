extends TDCardData
class_name PlacableObject_TDCardData

@export var OBJ_SCENE_PATH : NodePath
var object_to_spawn : PlacableObject
var my_rufus : PlayerCharacter

func _init(card_name : String, rufus : PlayerCharacter, obj_scene_path : NodePath):
	super._init(card_name)
	my_rufus = rufus
	OBJ_SCENE_PATH = obj_scene_path
	return

func SpecialSetup(_card : TDCard):
	if(_card is not BoBCard):
		printerr("Trying to set up a placable object card data on a non-BoB Card")
		return
	object_to_spawn = load(OBJ_SCENE_PATH).instantiate()
	GameManager.object_spawner.add_spawnable_scene(OBJ_SCENE_PATH)
	var card : BoBCard = _card as BoBCard
	
	if(not card.background):
		card.background = card.get_node("Background")
	if(not card.icon):
		card.icon = card.get_node("Background/Icon")
	if(not card.money_text):
		card.money_text = card.get_node("Background/MoneyText")
	
	
	print("card.background = ",card.background)
	card.background.texture = object_to_spawn.background_color_texture
	card.icon.texture = object_to_spawn.icon
	object_to_spawn.queue_free()
	
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: SpecialSetup has not been implemented. card: " + CardName)
	return

#region Unused funcs
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
#endregion Unused funcs

func PlayCard(_playArea : TDCardPlayArea, _card : TDCard) -> void:
	print("attempting to play")
	#printerr("[CardData] CardData is intended to be used as an abstract class. Please create a new class and inherit it: PlayCard has not been implemented. card: " + card.cardName + " playType: " + playType)
	if(_playArea.ValidPlayType("activate")):
		print("Played card!")
		if(my_rufus):
			if(not my_rufus.is_holding):
				my_rufus.SpawnObject.rpc(OBJ_SCENE_PATH)
				
				#GameManager.add_placable_object.rpc(OBJ_SCENE_PATH, Vector2(0, -100) + my_rufus.global_position)
				_card.queue_free()
				_card.Played = true
		
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
