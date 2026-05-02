extends RigidBody2D
class_name PlacableObject

@export_category("Card Info")
@export var icon : Texture2D
@export var cost : int = 0
@export var backing_color : BackingColor = BackingColor.GREEN
enum BackingColor {GREEN, RED, ORANGE, BLUE}
const BLUE = preload("res://Assets/Sprites/Deck/Cards/BackingColors/blue.png")
const GREEN = preload("res://Assets/Sprites/Deck/Cards/BackingColors/green.png")
const ORANGE = preload("res://Assets/Sprites/Deck/Cards/BackingColors/orange.png")
const RED = preload("res://Assets/Sprites/Deck/Cards/BackingColors/red.png")
@onready var rigid_spawner: MultiplayerSpawner
@onready var sprite: Sprite2D = $Sprite2D

var isHeld : bool = false

@export_category("Object Info")
@export var hold_offset : float = 0
@export var is_static : bool = false

@export_category("Clickable Info")
@export var is_clickable : bool = false
@export var click_time_delay : float = 0.01
@export var hover_color : Color = Color(0.5,0.5,0.5,1)

var selecting : bool = false
var NeverCheckAgain : bool = false
var SpriteList : Array[Sprite2D] = []

signal item_placed

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
	#print(name, "'s file path is: ", self.scene_file_path)
	#Set authority to the Host to keep the client from sending duplicate data or incorrect simulation data
	set_multiplayer_authority(1)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#rigid_spawner = get_tree().get_first_node_in_group("PlacedObjectSpawner")
	#rigid_spawner.add_spawnable_scene(scene_file_path)
	#sprite = get_node("Sprite2D")
	
	GetAllSprites(self)
	
	input_pickable = is_clickable
	if(input_pickable):
		mouse_entered.connect(hovered)
		mouse_exited.connect(unhovered)
		
	#print(name, " HAS BEEN SPAWNED")
	pass # Replace with function body.

var sineCounter : float = 0
var is_hovered : bool = false

var og_z_index : int
func hovered():
	print("Hovered");
	selecting = true;
	sineCounter = 0;
	is_hovered = true;
	og_z_index = z_index
	z_index = 500

##Recursive function to get all Sprite2Ds and add them to this Object's SpriteList
func GetAllSprites(starterNode : Node):
	for node in starterNode.get_children(true):
		if(node is Sprite2D):
			SpriteList.append(node);
			print("Added");
		GetAllSprites(node);

func unhovered():
	is_hovered = false;
	if fuse and fuse.time_left <= 0:
		selecting = false;
	z_index = og_z_index

var fuse : SceneTreeTimer
func object_clicked(time_delay : float):
	fuse = get_tree().create_timer(time_delay)
	fuse.timeout.connect(func(): fuse = null)
	click_action()
	return

func click_action():
	print("click_action activated!")

func while_active_action():
	print("while_active_action is active!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_clickable:
		if (is_hovered && !isHeld && NeverCheckAgain):
			sprite.scale = sprite.scale.lerp(Vector2(1.25, 1.25), 0.25);
			sprite.modulate = modulate + hover_color
			#Make sure to only allow one click
			if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not fuse):
				object_clicked(click_time_delay);
		else:
			sprite.scale = sprite.scale.lerp(Vector2(1, 1), 0.25);
			sprite.modulate = Color(1, 1, 1, 1);
	
		if (!selecting):
			for item in SpriteList:
				if(has_node(item.get_path()) && item != null):
					if (item is Sprite2D):
						var sprt : Sprite2D = item
						sprt.scale = sprt.scale.lerp(Vector2(1, 1), 0.25)
						sprt.modulate = Color(1, 1, 1, 1)
		
		if(fuse):
			while_active_action()
		
	if (has_node("LockedSprite")):
		var locked = get_node("LockedSprite")
		if (locked != null):
			locked.global_position = global_position
	 
	if (!isHeld && !NeverCheckAgain):
		set_collision_layer_value(4, true)
		set_collision_mask_value(4, true)
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		if (get_collision_layer_value(1) == false):
			set_collision_layer_value(1, true)
			set_collision_mask_value(2, true)
			set_collision_layer_value(4, false)
			set_collision_mask_value(4, false)
			if (move_and_collide(Vector2(), true) != null):
				modulate.a = 0.5
				set_collision_layer_value(1, false)
				set_collision_mask_value(2, false)
			else:
			 
				modulate.a = 1
				set_collision_layer_value(1, true)
				set_collision_mask_value(2, true)
				item_placed.emit()
				NeverCheckAgain = true
				if (has_node("RigidBody2DBackground")):
				 
					var rigidBackground = get_node("RigidBody2DBackground")
					if (rigidBackground != null):
						rigidBackground.QueueFree()
			 
			set_collision_layer_value(4, true)
			set_collision_mask_value(4, true)
		 
		set_collision_mask_value(1, true)
	 
 
	pass
