extends TDCardBoard
class_name RufusCardBoard

var active_rufus : PlayerCharacter:
	set(value):
		my_rufus_label.text = value.name
		active_rufus = value
		if(value == null):
			hide()

@export var card_markers : Array[TDCardPositionMarker2D]
@onready var my_rufus_label: Label = $MyRufusLabel

func create_cards():
	var i = 0
	for marker : TDCardPositionMarker2D in card_markers:
		AddCardFromPackedScene(cardSceneSource, PlacableObject_TDCardData.new("TestCard" + str(i), active_rufus, "res://Scenes/PlacableRigids/Objects/crate.tscn"), true, true, marker)
		i+=1
	#AddCard(PlacableObject_TDCardData.new("TestCard2", active_rufus, "res://Scenes/PlacableRigids/Objects/crate.tscn"), true, true, card_markers.filter(func(a : TDCardPositionMarker2D): return !a.isFilled)[0])
	#AddCard(PlacableObject_TDCardData.new("TestCard3", active_rufus, "res://Scenes/PlacableRigids/Objects/crate.tscn"), true, true, card_markers.filter(func(a : TDCardPositionMarker2D): return !a.isFilled)[0])
	
	return
