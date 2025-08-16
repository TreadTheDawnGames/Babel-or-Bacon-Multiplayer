extends RigidBody2D
class_name PlacableObject

@export var icon : Texture2D
enum BackingColor {GREEN, RED, ORANGE, BLUE}
@export var backing_color : BackingColor = BackingColor.GREEN
const BLUE = preload("res://Assets/Sprites/Deck/Cards/BackingColors/blue.png")
const GREEN = preload("res://Assets/Sprites/Deck/Cards/BackingColors/green.png")
const ORANGE = preload("res://Assets/Sprites/Deck/Cards/BackingColors/orange.png")
const RED = preload("res://Assets/Sprites/Deck/Cards/BackingColors/red.png")

var background_color_texture : Texture2D:
	get:
		match backing_color:
			BackingColor.GREEN:
				return GREEN
			BackingColor.RED:
				return RED
			BackingColor.ORANGE:
				return ORANGE
			BackingColor.BLUE:
				return BLUE
			_:
				return GREEN
	set(value):
		printerr("Attempting to set 'background_color_texture.' This won't do anything because it's hardcoded to get a different color based on the enum: 'backing_color'")


func _enter_tree() -> void:
	#Set authority to the Host to keep the client from sending duplicate data or incorrect simulation data
	set_multiplayer_authority(1)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
