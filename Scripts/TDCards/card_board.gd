extends CanvasItem
class_name TDCardBoard

var _board : Array[TDCard]
var _selectedCards : Array[TDCard]
@export
var cardSceneSource : PackedScene



#var MONSTER_CARD : PackedScene = preload("res://scenes/cards/TDCard_Monster.tscn")
#var WEAPON_CARD : PackedScene = preload("res://scenes/cards/TDCard_Weapon.tscn")
#var BASE_CARD : PackedScene = preload("res://scenes/cards/card.tscn")
#var POTION_CARD : PackedScene = preload("res://scenes/cards/TDCard_base.tscn")
#var SHOP_CARD : PackedScene = preload("res://scenes/cards/TDCard_Shop.tscn")


###Adds a card to this board. 
func AddCard(data : TDCardData, isDragDroppable : bool, isActionUsable : bool, goToPos : TDCardPositionMarker2D = null) -> TDCard:
	var card = CreateCardFromPackedScene(data, isDragDroppable, isActionUsable, goToPos)
	if(!card):
		printerr("[TDCardBoard] Unable to create card to add to board.")
		return
	add_child(card, true)
	card.SetGrabbable(true)
	card.scale *= 4
	_board.push_back(card)
	return card

#func AddCardFromItsScene(data : TDCardData, isDragDroppable : bool, isActionUsable : bool, slot : TDCardPositionMarker2D = null) -> TDCard:
	#var card
	#if(data is TDCardData_Monster):
		#card = AddCardFromPackedScene(MONSTER_CARD, data, isDragDroppable, isActionUsable, slot)
	#elif(data is TDCardData_Weapon):
		#card = AddCardFromPackedScene(WEAPON_CARD, data, isDragDroppable, isActionUsable, slot)
	#elif(data is TDCardData_Ability):
		#card = AddCardFromPackedScene(POTION_CARD, data, isDragDroppable, isActionUsable, slot)
	#elif(data is TDCardData_Shop):
		#card = AddCardFromPackedScene(SHOP_CARD, data, isDragDroppable, isActionUsable, slot)
	#elif(data is TDCardData_Purchase):
		#card = AddCardFromPackedScene(BASE_CARD, data, isDragDroppable, isActionUsable, slot)
	#else:
		#if(data):
			#printerr("CardData not recognize for card \"" + data.CardName +".\" Defaulting to Base Card")
			#card = AddCardFromPackedScene(BASE_CARD, data, isDragDroppable, isActionUsable, slot)
		#else:
			#printerr("Unreconglized CardData: null")
	#return card

func AddCardFromPackedScene(source : PackedScene, data : TDCardData, isDragDroppable : bool, isActionUsable : bool, goToPos : TDCardPositionMarker2D = null) -> TDCard:
	var card = CreateCardFromPackedScene(data, isDragDroppable, isActionUsable, goToPos, source)
	if(!card):
		return
	add_child(card, true)
	card.SetGrabbable(true)
	_board.push_back(card)
	return card
	
func RemoveCard(card : TDCard):
	_board.erase(card)
	card.queue_free()
	return

func ContainsCard(card : TDCard) -> bool:
	return _board.has(card)

func SelectCard(card : TDCard) -> void:
	_selectedCards.push_back(card)
	return

func DeselectCard(card : TDCard) -> void:
	_selectedCards.erase(card)
	return

func DeselectAll() -> void:
	_selectedCards.resize(0)
	return

func CreateCardFromPackedScene(data : TDCardData, isDragDroppable : bool, isActionUsable : bool, goToPos : TDCardPositionMarker2D = null, source : PackedScene = null) -> TDCard:
	if(!data):
		var reason : String = ""
		if(!data):
			reason += "Data was null"
		reason += "."
		printerr("[CardBoard] Unable to create card: " + reason)
		return null
	var unpackedScene
	if(source):
		unpackedScene = source.instantiate()
	else:
		unpackedScene = cardSceneSource.instantiate()
	
	if(unpackedScene is TDCard):
		unpackedScene.SetUp(data, isDragDroppable, isActionUsable, goToPos)
	else:
		printerr("\""+unpackedScene.get_class()+"\"" + " is not a TDCard. The root node of your card object must be a TDCard.")
		unpackedScene.queue_free()
		return null
	return unpackedScene
	
func SetBoardActive(active : bool):
	for card in _board:
		if(is_instance_valid(card)):
			card.SetGrabbable(active)
	return
