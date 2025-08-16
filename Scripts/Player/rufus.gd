#thanks https://www.youtube.com/watch?v=V4a_J38XdHk
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

#*heldObject*
var holding : Node2D = null
var isHolding : bool = false
var pigArm : Node2D
var cam : Camera2D
var spawn : int
var coyoteTime : int = 0
var coyoteTimeMax : int = 10
var soundTick : int = 2
var stepSound : AudioStreamPlayer
var popSound : AudioStreamPlayer
var shiftyThought :    AnimatedSprite2D
var CanMakeLandSound : bool = false

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
@export var anim_velo : float = false
@export var jc1 : bool = false
@export var jc2 : bool = false

@onready var input_syncronizer: MultiplayerSynchronizer = $InputSyncronizer

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSyncronizer.set_multiplayer_authority(id)

func _handle_player_movement():
	end_jump = input_syncronizer.end_jump
	start_jump = input_syncronizer.start_jump
	move_left = input_syncronizer.move_left
	move_right = input_syncronizer.move_right
	is_interact = input_syncronizer.is_interact
	rotate_left = input_syncronizer.rotate_left
	rotate_right = input_syncronizer.rotate_right
	open_shop = input_syncronizer.open_shop


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
	

func _physics_process(_delta: float) -> void:
	
	_handle_player_movement()
	
	if(multiplayer.is_server()):
		_handle_physics()
		jc1 = move_and_collide(Vector2(0,1), true) == null
		jc2 = move_and_collide(Vector2(0,6), true) == null
		anim_velo = linear_velocity.x
	_handle_animation()
	#if(not multiplayer.is_server()):
		#print(jc1)
		#print(jc2)
		#print(anim_velo)
	#if(not is_multiplayer_authority()):
		#return

func _handle_physics():
	var spd = airspd
	#Move camera
	var linvel = linear_velocity
	
	
	## Vertical movement dampening
	#if (!GameManager.Instance.Camera.Zooming):
	#
	if (end_jump):
		linvel.y = max(linvel.y, minjump)
	
	
	# 

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
		var pos = position
		pos.x = clamp(pos.x,0,1920)
		position = pos
	
	#if (Input.IsActionJustPressed("OpenShop"))
	#	SpawnObject("res:#Scenes/PhysicsCardObjects/gascan.tscn")

	# Holding object
	if (holding != null):
		mySprite.Animation = "carry"
		var rigid : RigidBody2D = holding.get_node("RigidBody2D") as RigidBody2D
		# Handle pig arm position
		pigArm.global_position = global_position
		# Get direction to mouse
		var dir = global_position.direction_to(get_global_mouse_position())
		var mag = holding.GetMeta("HoldOffset")

			# Set object held position
		if (get_global_mouse_position().distance_to(global_position) < mag):
			holding.global_position = get_global_mouse_position()
		else:
			holding.global_position = Vector2(
				global_position.x + dir.x * mag,
				global_position.y + dir.y * mag
			)
		# Set facing sprite
		if (get_global_mouse_position().x > global_position.x):
		
			mySprite.FlipH = false
			pigArm.get_node("PigArm").FlipH = false
			pigArm.LookAt(get_global_mouse_position())
		
		if (get_global_mouse_position().x < global_position.x):
		
			mySprite.FlipH = true
			pigArm.get_node("PigArm").FlipH = true
			pigArm.LookAt(get_global_mouse_position())
			pigArm.Rotation += PI
		
		# Rotate held object
		if (rotate_left):
			holding.rotate((float)(-2/(180/PI)))
		if (rotate_right):
			holding.rotate((float)(2/(180/PI)))
		rigid.SetCollisionMaskValue(3, true)
		#rigid.SetCollisionMaskValue(4, true)
		if (rigid.move_and_collide(Vector2(0,.1), true) == null &&
			rigid.move_and_collide(Vector2(0,-.1), true) == null &&
			rigid.move_and_collide(Vector2(.1,0), true) == null && 
			rigid.move_and_collide(Vector2(-.1,0), true) == null &&
			rigid.move_and_collide(Vector2(.1,.1), true) == null &&
			rigid.move_and_collide(Vector2(.1,-.1), true) == null &&
			rigid.move_and_collide(Vector2(-.1,-.1), true) == null && 
			rigid.move_and_collide(Vector2(-.1,.1), true) == null):
		
			var modu = holding.Modulate
			modu.R = 1
			modu.B = 1
			modu.G = 1
			modu.A = 0.5
			holding.Modulate = modu
		
		else:
		
			var modu = holding.Modulate
			modu.R = 1
			modu.G = 0
			modu.B = 0
			modu.A = 0.5
			holding.Modulate = modu
		
		rigid.SetCollisionMaskValue(3, false)
		#rigid.SetCollisionMaskValue(4, false)
		# Place held object
		if (is_interact && isHolding == true):
		
			rigid.SetCollisionMaskValue(3, true)
			#rigid.SetCollisionMaskValue(4, true)
			if (rigid.move_and_collide(Vector2(0,.1), true) == null &&
				rigid.move_and_collide(Vector2(0,-.1), true) == null &&
				rigid.move_and_collide(Vector2(.1,0), true) == null && 
				rigid.move_and_collide(Vector2(-.1,0), true) == null &&
				rigid.move_and_collide(Vector2(.1,.1), true) == null &&
				rigid.move_and_collide(Vector2(.1,-.1), true) == null &&
				rigid.move_and_collide(Vector2(-.1,-.1), true) == null && 
				rigid.move_and_collide(Vector2(-.1,.1), true) == null):
			
				if(holding.GetMeta("Static") == false):
					rigid.Freeze = false
					rigid.linear_velocity = linear_velocity
				
				else:
				
					rigid.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
				
				holding.isHeld = false
				isHolding = false
				holding = null
				PlayPopSound()
				pigArm.QueueFree()
				pigArm = null
			
			rigid.SetCollisionMaskValue(3, false)
			#rigid.SetCollisionMaskValue(4, false)
		
		else:
			isHolding = true
	
	else:
	
		mySprite.animation = "normal"
	


func SpawnObject(path : String) -> bool:

	if(holding!=null):
		return false
		
	var ps = load(path)
	var inst = ps.instantiate()
	get_tree().root.add_child(inst)
	var rigid = inst.GetNode<RigidBody2D>("RigidBody2D")
	inst.AddToGroup("PhysicsObjects", false)
	rigid.SetCollisionLayerValue(1, false)
	rigid.SetCollisionMaskValue(2, false)
	rigid.Freeze = true
	holding = inst
	
	holding.isHeld = true
	ps = load("res:#Scenes/pig_hold_arm.tscn")
	inst = ps.instantiate()
	inst.AddToGroup("PhysicsObjects", false)
	get_tree().root.add_child(inst)
	pigArm = inst
	# Handle pig arm position
	pigArm.global_position = global_position
	# Get direction to mouse
	var dir = global_position.direction_to(get_global_mouse_position())
	var mag = holding.GetMeta("HoldOffset")
	# Set object held position
	if (get_global_mouse_position().distance_to(global_position) < mag):
		holding.global_position = get_global_mouse_position()
	else:
		holding.global_position = Vector2(
			global_position.x + dir.x * mag,
			global_position.y + dir.y * mag
		)
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

	if(pigArm!=null):
		pigArm.queue_free()
	
	if (holding != null):
		holding.queue_free()
	
	#var rufusRagPS = load("res://RufusRagdoll.tscn")
	#var rufusRag = rufusRagPS.instantiate()
	#rufusRag.global_position = global_position
	#get_tree().root.add_child(rufusRag)
	#rufusRag.get_node("Sprite2D").FlipH = mySprite.FlipH
	GameManager.Rufuses.erase(self)
	queue_free()
