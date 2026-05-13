extends MultiplayerSynchronizer
class_name RufusInputSynchronizer

var end_jump : bool = false
var start_jump : bool = false
var move_right : bool = false
var move_left : bool = false
var is_interact : bool = false
var rotate_left : bool = false
var rotate_right : bool = false
var open_shop : bool = false
var mouse_position : Vector2
var mouse_direction : Vector2

var rufus : PlayerCharacter

func _ready():
	if(get_multiplayer_authority() != multiplayer.get_unique_id()):
		set_process(false)
		set_physics_process(false)
	
	end_jump = Input.is_action_just_released("jump")
	start_jump = Input.is_action_just_pressed("jump")
	move_left = Input.is_action_pressed("left")
	move_right = Input.is_action_pressed("right")
	is_interact = Input.is_action_pressed("interact")
	rotate_left = Input.is_action_pressed("rotate_left")
	rotate_right = Input.is_action_pressed("rotate_right")
	open_shop = Input.is_action_just_pressed("open_shop")
	mouse_position = get_parent().get_global_mouse_position()
	rufus = get_parent()
	mouse_direction = Vector2(Input.get_axis("mouse_direction-LEFT", "mouse_direction-RIGHT"), Input.get_axis("mouse_direction-UP", "mouse_direction-DOWN"))
	pass

func _physics_process(_delta: float) -> void:
	end_jump = Input.is_action_just_released("jump")
	start_jump = Input.is_action_just_pressed("jump")
	move_left = Input.is_action_pressed("left")
	move_right = Input.is_action_pressed("right")
	is_interact = Input.is_action_pressed("interact")
	rotate_left = Input.is_action_pressed("rotate_left")
	rotate_right = Input.is_action_pressed("rotate_right")
	open_shop = Input.is_action_just_pressed("open_shop")
	mouse_position = get_parent().get_global_mouse_position()
	mouse_direction = Vector2(Input.get_axis("mouse_direction-LEFT", "mouse_direction-RIGHT"), Input.get_axis("mouse_direction-UP", "mouse_direction-DOWN"))


	pass
