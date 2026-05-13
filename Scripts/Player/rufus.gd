#thanks https://www.youtube.com/watch?v=V4a_J38XdHk
#https://www.youtube.com/watch?v=Sc_pP_nKSL8
extends RigidBody2D
class_name PlayerCharacter

var vel : Vector2 = Vector2.ZERO
@export var airspd : float = 3500.0
@export var grndspd : float = 5500.0
@export var maxSpd : float = 500.0
@export var maxjump : float = -1000.0
@export var minjump : float = -600.0
var ticker : float = 0.0
var tickerMax : int = 10
var tickRate : int = 0
var curFrame : int = 0
@onready var mySprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pig_arm: Node2D = $ArmSlot/PigHoldArm
@onready var arm_slot: Node2D = $ArmSlot
#@onready var object_spawner: MultiplayerSpawner = $ObjectSpawner

#*heldObject*
var holding : Node2D = null
var cam : Camera2D
var spawn : int
var coyoteTime : int = 0
var coyoteTimeMax : int = 10
var soundTick : int = 2
var stepSound : AudioStreamPlayer
var popSound : AudioStreamPlayer
var shiftyThought :    AnimatedSprite2D
var CanMakeLandSound : bool = false
@export var is_holding : bool = false
#set auth to local
#func _enter_tree() -> void:
	#set_multiplayer_authority(str(name).to_int())
#
func _ready():
	shiftyThought = get_node("ShiftyThoughts")
	shiftyThought.hide()
	
	#if(not is_multiplayer_authority()):
		#return
	
	vel = Vector2()
	mySprite = get_node("AnimatedSprite2D")
	#cam = get_tree().root.get_node("LevelField/Camera")
	stepSound = get_node("StepSoundPlayer")
	popSound = get_node("PopSoundPlayer")
	add_to_group("PhysicsObjects", false)

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

@export var anim_velo : float = false
@export var jc1 : bool = false
@export var jc2 : bool = false

@onready var input_syncronizer: RufusInputSynchronizer = $InputSyncronizer

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSyncronizer.set_multiplayer_authority(id)

func _handle_player_input():
	end_jump = input_syncronizer.end_jump
	start_jump = input_syncronizer.start_jump
	move_left = input_syncronizer.move_left
	move_right = input_syncronizer.move_right
	is_interact = input_syncronizer.is_interact
	rotate_left = input_syncronizer.rotate_left
	rotate_right = input_syncronizer.rotate_right
	open_shop = input_syncronizer.open_shop
	mouse_position = input_syncronizer.mouse_position
	mouse_direction = input_syncronizer.mouse_direction

func _physics_process(_delta: float) -> void:
	
	_handle_player_input()
	
	if(multiplayer.is_server()):
		_handle_physics()
		jc1 = move_and_collide(Vector2(0,1), true) == null
		jc2 = move_and_collide(Vector2(0,6), true) == null
		anim_velo = linear_velocity.x
		handle_holding_object()
	
	
	_handle_animation()
	#if(not multiplayer.is_server()):
		#print(jc1)
		#print(jc2)
		#print(anim_velo)
	#if(not is_multiplayer_authority()):
		#return

func _handle_animation():
	
	#Whether to face right or left based on movement. Ignore if holding because you're gonna face the mouse.
	if(move_right):
		if(holding == null):
			mySprite.flip_h = false

	if (move_left):
		if (holding == null):
			mySprite.flip_h = true
			
	# Get animation tick rate
	tickRate = abs(anim_velo)/100
	if (jc1):
		if (jc2):
			curFrame = 1
		else:
			curFrame = 0
		soundTick = 0
	elif (abs(anim_velo) > 0.5):
		if (ticker >= tickerMax):
			ticker = 0
			curFrame += 1
			if (curFrame == 1 || curFrame == 3):
				PlayStepSound()
			curFrame %= 4
		else:
			ticker+=tickRate
	else:
		curFrame = 0
	
	mySprite.frame = curFrame
	
	if(is_holding):
		mySprite.animation = "carry"
		arm_slot.show()
		
		if mouse_direction.x > 0:
			mySprite.flip_h = false
			pig_arm.get_node("PigArm").flip_h = false
			pig_arm.rotation = mouse_direction.angle()
		if mouse_direction.x < 0:
			mySprite.flip_h = true
			pig_arm.get_node("PigArm").flip_h = true
			pig_arm.rotation = mouse_direction.angle()
			pig_arm.rotation += PI

		
		#if (mouse_position.x > global_position.x):
		## Set facing sprite
			#mySprite.flip_h = false
			#pig_arm.get_node("PigArm").flip_h = false
			#pig_arm.look_at(mouse_position)
		#
		#if (mouse_position.x < global_position.x):
			#mySprite.flip_h = true
			#pig_arm.get_node("PigArm").flip_h = true
			#pig_arm.look_at(mouse_position)
			#pig_arm.rotation += PI
	else:
		mySprite.animation = "normal"
		arm_slot.hide()

func _handle_physics():
	var spd = airspd
	var linvel = linear_velocity
	## disallow movement if zooming
	#if (!GameManager.Instance.Camera.Zooming):
	#
	if (end_jump):
		linvel.y = max(linvel.y, minjump)
	# Horizontal movement dampening
	linvel.x = clamp(linvel.x, -maxSpd, maxSpd)
	linvel.x /= 1.25
	linear_velocity = linvel

	# Handle animation
	anim_velo = linvel.x

	if (move_and_collide(Vector2(0,5), true) == null):
		CanMakeLandSound = true
	var hit = move_and_collide(Vector2.DOWN, true)
	# Jump movement
	if (hit != null):
		#if (linvel.y < 0)
			#apply_force(Vector2(0,(int)ProjectSettings.GetSetting("physics/2d/default_gravity")), Vector2(Position.x, Position.y - 10))
		var vec = hit.get_normal()
		#GD.Print(Convert.ToString(vec.x) + "," + Convert.ToString(vec.y))
		if (abs(vec.y) > 0.4):
			linvel.x /= 1.5
			linear_velocity = linvel
		else:
			linvel.x /= 1.5
			linear_velocity = linvel
			apply_force(Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity")), Vector2(position.x, position.x - 10))
		spd = grndspd
		if (coyoteTime < coyoteTimeMax && CanMakeLandSound):
			PlayLandSound()
			CanMakeLandSound = false
		
		coyoteTime = coyoteTimeMax
	
	else:
	
		coyoteTime -= 1
		apply_force(Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity")), Vector2(position.x, position.y - 10))
	
##Handle movement if camera isn't zooming
	#if (!GameManager.Instance.Camera.Zooming):
	if (start_jump && coyoteTime > 0):
		PlayJumpSound()
		linvel.y = 0
		linear_velocity = linvel
		apply_impulse(Vector2(0, maxjump), Vector2(position.x, position.y + 10))
		coyoteTime = 0
	# Horizontal movement
	if (move_right):
		apply_force(Vector2(spd, 0))
	
	if (move_left):
		apply_force(Vector2(-spd, 0))

	# Clamp position
		global_position.x = clamp(global_position.x,0,1920)
	
	#if (Input.IsActionJustPressed("OpenShop"))
	#	SpawnObject("res:#Scenes/PhysicsCardObjects/gascan.tscn")

	# Holding object

func handle_holding_object():
	if (is_holding):
		if holding is not PlacableObject:
			push_error("Holding an object that is not a PlacableObject.")
			return
		var rigid : PlacableObject = holding as PlacableObject
		# Get direction to mouse
		#var dir = global_position.direction_to(mouse_position)
		var dir =input_syncronizer.mouse_direction
		var maxMag = holding.hold_offset

			# Set object held position
		#if (mouse_position.distance_to(global_position) < maxMag):
			#holding.global_position = mouse_position
		#else:
			#holding.global_position = Vector2(
				#global_position.x + dir.x * maxMag,
				#global_position.y + dir.y * maxMag
			#)
			
		holding.global_position = global_position+(dir*maxMag)
		
		# Rotate held object
		if (rotate_left):
			holding.rotate(-2/(180/PI))
		if (rotate_right):
			holding.rotate(2/(180/PI))
		rigid.set_collision_mask_value(3, true)
		#rigid.set_collision_mask_value(4, true)
		if (rigid.move_and_collide(Vector2(0,.1), true) == null &&
			rigid.move_and_collide(Vector2(0,-.1), true) == null &&
			rigid.move_and_collide(Vector2(.1,0), true) == null && 
			rigid.move_and_collide(Vector2(-.1,0), true) == null &&
			rigid.move_and_collide(Vector2(.1,.1), true) == null &&
			rigid.move_and_collide(Vector2(.1,-.1), true) == null &&
			rigid.move_and_collide(Vector2(-.1,-.1), true) == null && 
			rigid.move_and_collide(Vector2(-.1,.1), true) == null):
			holding.modulate = Color(1,1,1,0.5)
		else:
			holding.modulate = Color(1,0,0,0.5)
		
		rigid.set_collision_mask_value(3, false)
		#rigid.set_collision_mask_value(4, false)
		# Place held object
		if (is_interact && is_holding == true):
			rigid.set_collision_mask_value(3, true)
			#rigid.set_collision_mask_value(4, true)
			if (rigid.move_and_collide(Vector2(0,0.1), true) == null &&
				rigid.move_and_collide(Vector2(0,-0.1), true) == null &&
				rigid.move_and_collide(Vector2(0.1,0), true) == null && 
				rigid.move_and_collide(Vector2(-0.1,0), true) == null &&
				rigid.move_and_collide(Vector2(0.1,0.1), true) == null &&
				rigid.move_and_collide(Vector2(0.1,-0.1), true) == null &&
				rigid.move_and_collide(Vector2(-0.1,-0.1), true) == null && 
				rigid.move_and_collide(Vector2(-0.1,0.1), true) == null):
			
				if(holding.is_static == false):
					rigid.freeze = false
					rigid.linear_velocity = linear_velocity
				else:
					rigid.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
				#holding.reparent(get_tree().get_first_node_in_group("ObjectHolder"), true)
				holding.isHeld = false
				is_holding = false
				holding = null
				PlayPopSound()
				arm_slot.hide()
			
			rigid.set_collision_mask_value(3, false)
			#rigid.set_collision_mask_value(4, false)
		else:
			is_holding = true

	

@rpc("any_peer", "call_local")
func SpawnObject(path : String) -> bool:
	#We want holding to be null. If it's not null then it'll try to make Rufus hold two objects
	#object_spawner.add_spawnable_scene(path)
	
	if(not is_multiplayer_authority()):
		return false
	if(is_holding):
		print("is_holding")
		return false
	
	
	#get the packed scene from the provided path
	var ps = load(path)
	#instantiate the packed scene
	var inst : PlacableObject = ps.instantiate()
	#add the scene to the tree
	GameManager.object_holder.add_child(inst, true)
	#arm_slot.move_child(inst, 0)
	#get the rigidbody of the spawned placable object
	#add it to the physics objects group
	#inst.add_to_group("PhysicsObjects", false)
	#make it so it doesn't collide with anything
	inst.set_collision_layer_value(1, false)
	inst.set_collision_mask_value(2, false)
	#turn off physics
	inst.freeze = true
	#Tell Rufus he's holding the unpacked placable object
	holding = inst
	#tell the placable object it's being held
	holding.isHeld = true
	
	#change original packed scene to a pig arm and instantiate it
	
	# Get direction to mouse
	var dir = global_position.direction_to(mouse_position)
	var mag = holding.hold_offset
	# Set object held position
	if (mouse_position.distance_to(global_position) < mag):
		holding.global_position = mouse_position
	else:
		holding.global_position = Vector2(
			global_position.x + dir.x * mag,
			global_position.y + dir.y * mag
		)
	is_holding = true
	return true

func PlayStepSound():
#if (soundTick != 0)
#
	soundTick = 2 if soundTick == 1 else 1
	stepSound.stream = load("res://Assets/Sounds/soStep" + str(soundTick) + ".wav")
	stepSound.play()
#
#else:
	#soundTick = 2

func PlayPopSound():
		var rand = (int)(randi() % 3)
		popSound.stream = load("res://Assets/Sounds/SpawnObject" + str(rand) + ".wav")
		popSound.play()

func PlayJumpSound():
	stepSound.stream = load("res://Assets/Sounds/soJump.wav")
	stepSound.play()

func PlayLandSound():

	stepSound.stream = load("res://Assets/Sounds/soLand.wav")
	stepSound.play()

func ThinkShifyThoughts(isShify : bool):

	if(has_node("ShiftyThoughts")):
		shiftyThought.Visible = isShify

func Despawn():

	if (holding != null):
		holding.queue_free()
	
	#var rufusRagPS = load("res://RufusRagdoll.tscn")
	#var rufusRag = rufusRagPS.instantiate()
	#rufusRag.global_position = global_position
	#get_tree().root.add_child(rufusRag)
	#rufusRag.get_node("Sprite2D").flip_h = mySprite.flip_h
	GameManager.Rufuses.erase(self)
	queue_free()
