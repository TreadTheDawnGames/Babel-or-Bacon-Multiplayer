extends Camera2D
class_name CameraZoomer

var Deck : Control
var ResetButton : Control
var Home : Vector2
var slowScrollTimer : int = 50
var slowScrollTimerMax : int = 25
var timerActive : bool = false
var GameOver : bool = false
var maxCamHeight : float  
var Zooming : bool 

# Called when the node enters the scene tree for the first time.
func _ready():
	#GameManager = get_parent()
	Home = global_position
	#Deck = get_node("CanvasLayer/Deck")
	#ResetButton = get_node("CanvasLayer/ResetGameButton")
	maxCamHeight = -460
	slowScrollTimer = slowScrollTimerMax
	

	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(multiplayer.is_server()):
	#if ((Input.is_action_just_pressed("ZoomOut")|| Input.is_action_just_pressed("SlowScrollDown"))&&!Zooming):
		#@warning_ignore("narrowing_conversion")
		#absMouseWheeleDisplacement = maxCamHeight
		#if (Input.is_action_pressed("FullZoomOut") && !timerActive):
			#FullZoomOut(0.25)
			#return
		#elif (Input.is_action_pressed("SlowScrollDown") && !GameOver):
			#ScrollableZoom()
			#slowScrollTimer-=1
			#if (slowScrollTimer < 0):
				#timerActive = true
				#if (absMouseWheeleDisplacement < Home.y && absMouseWheeleDisplacement >= maxCamHeight):
					#absMouseWheeleDisplacement += 10
			#else:
				#timerActive = false
			#return
		#elif (Input.is_action_pressed("ZoomOut") && !GameOver && !timerActive):
			#ScrollableZoom()
			#return
		#elif (!GameOver &&!Input.is_action_pressed("FullZoomOut")&&!timerActive && !Input.is_action_pressed("SlowScrollDown")):
			#Zooming = false
			#initializePosition = false
			#absMouseWheeleDisplacement = 0
			#zoom = zoom.lerp(Vector2.ONE, 0.05)
			#Deck.Modulate = Deck.Modulate.lerp(Color.WHITE, 0.25)
			#if (!GameOver):
				#ResetButton.Modulate = ResetButton.Modulate.lerp(Color(1, 1, 1, 1), 0.25)
				#ResetButton.Scale = ResetButton.Scale.lerp(Vector2(1, 1), 0.25)
			#Deck.process_mode = Node.PROCESS_MODE_ALWAYS
		global_position = global_position.lerp(Vector2(global_position.x, maxCamHeight), 0.1)

##Game manager doesn't exist
##This is what makes it go up
# Get an array of connected players and check for each player. Could store a max height on each of the players and compare to that
		for rufus in GameManager.Rufuses:
			if (rufus.global_position.y < maxCamHeight):
				maxCamHeight = rufus.global_position.y
				@warning_ignore("integer_division")
				GameManager.loseHeight = global_position.y + 1080 / 2 + 35
		
		#if (Input.is_action_just_released("SlowScrollDown")):
			#slowScrollTimer = slowScrollTimerMax 
			#timerActive = false
			
			
var initializePosition :bool = false
var absMouseWheeleDisplacement : int = 0

var workingPosition : Vector2 = Vector2(0,0)
func ScrollableZoom():
	Zooming = true
	zoom = zoom.lerp(Vector2(0.5, 0.5), 0.05)
	Deck.Modulate = Deck.Modulate.lerp(Color(1, 1, 1, 0), 0.25)
	if (!GameOver):
		ResetButton.Modulate = ResetButton.Modulate.lerp(Color(1, 1, 1, 0), 0.25)
		ResetButton.Scale = ResetButton.Scale.lerp(Vector2(0, 0), 0.25)

		if(absMouseWheeleDisplacement >= maxCamHeight):
			workingPosition.y =  absMouseWheeleDisplacement
			
		global_position = global_position.lerp(Vector2(global_position.x, workingPosition.y), 0.1)

func FullZoomOut(speed:float):
	var goToMultiplier = 0.5
	if (maxCamHeight >= -1000):
		goToMultiplier = 0.75
		#LimitTop = (int)deck.global_position.y
		Zooming = true
		Deck.Modulate = Deck.Modulate.lerp(Color(1, 1, 1, 0), 0.25)
		if (!GameOver):
			ResetButton.Modulate = ResetButton.Modulate.lerp(Color(1, 1, 1, 0), 0.25)
		ResetButton.Scale = ResetButton.Scale.lerp(Vector2(0, 0), 0.25)
		Deck.process_mode = PROCESS_MODE_DISABLED
		global_position = global_position.lerp(Vector2(Home.x, (maxCamHeight * goToMultiplier)), speed)
		var zoomPower = clamp((1080) / -maxCamHeight, 0, 0.75)

		if (zoomPower > 0):
			zoom = zoom.lerp(Vector2(zoomPower, zoomPower), speed)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		var emb : InputEventMouseButton = event
		if (emb.is_pressed()):
			if (emb.button_index == MOUSE_BUTTON_WHEEL_UP):
				if(absMouseWheeleDisplacement>=maxCamHeight):
					absMouseWheeleDisplacement -= 75
				if(absMouseWheeleDisplacement<maxCamHeight):
					@warning_ignore("narrowing_conversion")
					absMouseWheeleDisplacement = maxCamHeight
			if (emb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
				if(absMouseWheeleDisplacement<Home.y):
					@warning_ignore("narrowing_conversion")
					absMouseWheeleDisplacement+=75
				if (absMouseWheeleDisplacement >=Home.y):
					@warning_ignore("narrowing_conversion")
					absMouseWheeleDisplacement = Home.y
