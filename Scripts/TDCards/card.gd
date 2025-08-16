extends Area2D
class_name TDCard
var area2D;

var grabbed : bool = false
var _hovered : bool = false;
@export var preventHoverAction : bool = false;
@export
var returnSpeed : float = 5.0
var debugName : String = "TDCard"
static var hoveredCards : Array[TDCard]

var _grabbedOffset : Vector2;
var _lastMousePos : Vector2;
@export var LocationMarker : TDCardPositionMarker2D;
@onready var grab_area: CollisionShape2D = $GrabArea

@export var Data : TDCardData

var usable : bool = false

var CardName : String = ""

var _OGMask : int

var _PlayZone : TDCardPlayArea = null

var _Played : bool

@export var _IsDragDropable : bool = true
@export var _IsActionUsable : bool = true

@export var ManualSetup : bool = false

func _ready():
	if(ManualSetup):
		SetUp(Data, _IsDragDropable, _IsActionUsable, LocationMarker)

func SetUp(data : TDCardData, isDragDroppable : bool, isActionUsable : bool, marker : TDCardPositionMarker2D = null) -> void:
	area_entered.connect(CardEnteredZone)
	area_exited.connect(CardExitedZone)
	grab_area = get_node("GrabArea")
	mouse_entered.connect(Hovered)
	mouse_exited.connect(Unhovered)
	_IsActionUsable = isActionUsable
	_OGMask = collision_mask
	SetGrabbable(isDragDroppable)
	if(marker != null):
		FillMarker(marker)
	
	if(data):
		Data = data
		CardName = Data.CardName
		Data.SpecialSetup(self)
	return
	
func SetGrabbable(canGrab : bool) -> void:
	collision_mask = _OGMask if canGrab else 0
	set_collision_layer_value(17, canGrab)
	return

##A private function that calls the Preplay, PlayCard, and Postplay functions for the Data if it is not null
func _PlayCard() -> void:
	if(_PlayZone && Data):
		if(grabbed && usable && not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && not _Played):
			usable = false
			Data.Preplay(_PlayZone, self)
			Data.PlayCard(_PlayZone, self)
			_Played = true
			Data.Postplay(_PlayZone, self)
	return

func _DragDropLogic(delta : float) -> void:
	if(_hovered):
		if(Data):
			Data.WhileHovered(self)
			
		if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not grabbed):
			if(IsOnTop()):
				_grabbedOffset = global_position - get_global_mouse_position()
				grabbed = true
				if(Data):
					Data.GrabAction(self)
				
		elif(not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and grabbed):
			grabbed = false
			if(Data):
				Data.DropAction(self)
		_lastMousePos = get_global_mouse_position()

	if(_PlayZone and !usable):
		usable = true
		if(Data):
			Data.EnterUsable(_PlayZone, self)
	elif(!_PlayZone and usable):
		usable = false
		if(Data):
			Data.ExitUsable(self)
		
	if(grabbed):
		global_position = get_global_mouse_position() + _grabbedOffset
	elif LocationMarker != null:
		if(LocationMarker):
			if(global_position.distance_to(LocationMarker.global_position) > 0.01):
				global_position = global_position.lerp(LocationMarker.global_position, returnSpeed * delta)
	return

func _process(delta: float) -> void:
	if(Data):
		Data.Frame(self, delta)
	if(_IsActionUsable):
		_PlayCard()
	if(_IsDragDropable):
		_DragDropLogic(delta)
	return

func Hovered() -> void:
	if(preventHoverAction):
		return
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		return
	hoveredCards.append(self)
	#add_to_group("DraggableHovered")
	_hovered = true
	if(Data):
		Data.HoverEnterAction(self)
	return

func Unhovered() -> void:
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		return
	#remove_from_group("DraggableHovered")
	hoveredCards.erase(self)
	if(Data):
		Data.HoverExitAction(self)
	_hovered = false
	return
	
func CardEnteredZone(node : Node2D) -> void:
	if(node is not TDCardPlayArea):
		return
	_PlayZone = node
	return
	
func CardExitedZone(node : Node2D) -> void:
	if(node is not TDCardPlayArea):
		return
	if(node == _PlayZone):
		_PlayZone = null
	return
	
func IsOnTop() -> bool:
	if(TDCard.hoveredCards.size() > 0):
		return TDCard.hoveredCards[-1] == self #().get_nodes_in_group("DraggableHovered"):
	else:
		return false

##Remember to free the marker before freeing the card.
func FreeMarker():
	if(LocationMarker):
		LocationMarker.SetUnfilled()
	LocationMarker = null
	return

## Automatically frees the current marker if the card already has one.
func FillMarker(marker : TDCardPositionMarker2D):
	if(LocationMarker):
		FreeMarker()
	if(marker):
		marker.SetFilled()
		LocationMarker = marker
	else:
		printerr("Attempted to set card marker to a null instance.")
	return

#technically got this name from Brave AI
func _exit_tree() -> void:
	if(is_instance_valid(LocationMarker)):
		FreeMarker()
		#printerr(name + ": Make sure to free the card marker first!")
	TDCard.hoveredCards.erase(self)
	return

func StopMouseDetectable():
	grab_area.disabled = true
	grabbed = false
	return
func StartMouseDetectable():
	grab_area.disabled = false
	return
