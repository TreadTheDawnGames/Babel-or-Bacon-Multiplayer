#pennyloafers: https://forum.godotengine.org/t/p2p-networked-physics-inaccuracy-seeking-help/45340/8

class_name PhysicsSynchronizer
extends MultiplayerSynchronizer

@onready var sync_object : PhysicsBody2D = get_node(root_path)
@onready var body_state : PhysicsDirectBodyState2D = \
	PhysicsServer2D.body_get_direct_state( sync_object.get_rid() )
@export var sync_pos   : Vector2
@export var sync_lvel  : Vector2
@export var sync_avel  : float
@export var sync_rot  : float
@export var sync_frame : int = 0

var ring_buffer:RingBuffer = RingBuffer.new()

var last_frame = -1
var set_num = 0

enum {
	ORIGIN,
	LIN_VEL,
	ANG_VEL,
	QUAT, # the quaternion is used for an optimized rotation state
}


func _ready():
	synchronized.connect(_on_synchronized)

func _exit_tree():
	ring_buffer.free()

#copy state to array
func get_state(state : PhysicsDirectBodyState2D ):
	sync_pos = state.transform.origin
	#sync_rot = state.transform.get_rotation()
	sync_lvel = state.linear_velocity
	sync_avel = state.angular_velocity


#copy array to state
func set_state(state : PhysicsDirectBodyState2D, data:Array ):
	state.transform.origin = data[ORIGIN]
	state.linear_velocity = data[LIN_VEL]
	state.angular_velocity = data[ANG_VEL]
	
	#state.transform = state.transform.rotated(data[QUAT])


func get_physics_body_info():
	# server copy for sync
	get_state( body_state )

@rpc
func set_physics_body_info():
	# client rpc set from server
	var data :Array = ring_buffer.remove()
	while data.is_empty():
		return
	set_state( body_state, data )


func _physics_process(_delta):
	if is_multiplayer_authority():
		sync_frame += 1
		get_physics_body_info()
	else:
		set_physics_body_info()


# make sure to wire the "synchronized" signal to this function
func _on_synchronized():
	if is_previouse_frame():
		return
	ring_buffer.add([
		sync_pos,
		sync_lvel,
		sync_avel,
		sync_rot,
	])


func is_previouse_frame() -> bool:
	if sync_frame <= last_frame:
		#print("previous frame %d %d" % [sync_frame, last_frame] )
		return true
	else:
		last_frame = sync_frame
		return false

class RingBuffer extends Object:
	const SAFETY:int = 1
	const CAPACITY:int = 4 + SAFETY
	var buf:Array[Array]
	var head:int = 0
	var tail:int = 0

	func _init():
		buf.resize(CAPACITY)

	func add(frame:Array):
		if _increment(head) == tail: # full
			_comsume_extra()
		if is_low():
			_produce_extra(frame)
		buf[head]=frame
		head = _increment(head)

	func _comsume_extra():
		#print( "RingBuffer: consume_extra")
		var next_index = _increment(tail)
		buf[next_index] = _interpolate(buf[tail], buf[next_index],0.5)
		tail = next_index

	func _produce_extra(frame:Array):
		#print("RingBuffer: produce_extra")
		var first_frame = _interpolate(buf[tail],frame, 0.33) # assume only one frame exists tail should point at it
		var second_frame = _interpolate(buf[tail],frame, 0.66) # assume only one frame exists tail should point at it
		buf[head]=first_frame
		head = _increment(head)
		buf[head] = second_frame
		head = _increment(head)

	func _interpolate(from:Array, to:Array, percentage:float) -> Array:
		var frame:Array = [
			
			lerp(from[ORIGIN], to[ORIGIN], percentage),
			lerp(from[LIN_VEL], to[LIN_VEL], percentage),
			lerp(from[ANG_VEL], to[ANG_VEL], percentage),
			lerp(from[QUAT], to[QUAT], percentage)
		]
		return frame

	func _increment(index:int)->int:
		index += 1
		if index == CAPACITY: # avoid modulus
			index = 0
		return index

	func remove() -> Array:
		var frame : Array = buf[tail]
		if is_empty() or is_low():
			frame = []
		else:
			tail = _increment(tail)
		return frame

	func is_empty() -> bool:
		return tail == head

	func is_low() -> bool:
		return _increment(tail) == head
