extends Node


@export
var startingMoney : int = 20
var musicPlayer : AudioStreamPlayer
var moneyOwned : int
var score : int = 0
var highScore : int
var moneyLineHeight : int = -880
var moneyLineScene : PackedScene # = preload("res://Scenes/money_line.tscn")
#var Camera : CameraZoomer 
var Rufuses : Array[PlayerCharacter]
#var moneyLabel : RichTextLabel
var gameOverInst : Node2D
var loseHeight : int
	
	
func _ready():
	#Camera = get_node("Camera2D")
	#moneyLabel = get_node("Camera/CanvasLayer/Deck/MoneyLabel")
	#Rufus = get_node("Rufus")
	#cam = get_node("Camera")
	
	if (get_tree().root.has_node("MusicPlayer")):
		musicPlayer = get_tree().root.get_node("level/MusicPlayer")
		# musicPlayer.Reparent(GetTree().Root, false)
		#musicPlayer.reparent.call_deferred(get_tree().root, false)
		musicPlayer.stream = load("res://Assets/Sounds/CalmPiggiesLoop.wav")
		musicPlayer.volume_db = -40
		musicPlayer.play()
	
	#else:
		#musicPlayer = get_tree().root.get_node("MusicPlayer")
		#if (musicPlayer.Stream.ResourcePath.GetFile() != "CalmPiggiesLoop.wav"):
		#
			#musicPlayer.Stop()
			#musicPlayer.Stream = load("res://Assets/Sounds/CalmPiggiesLoop.wav")
			#musicPlayer.VolumeDb = -40
			#musicPlayer.Play()
		
	
		#UpdateMoney(startingMoney)
	#highScore = PlayerPrefs.GetInt("HighScore", 0)
	#DeckManager.Instance.highScoreLabel.Text = "High Score: " + (-highScore -169).ToString()
	#DeckManager.Instance.scoreLabel.Text = "Score: " + (-score-169).ToString()
	#SpawnMoneyLine(moneyLineHeight)

#func SpawnMoneyLine(float height) -> MoneyLine:
	#var ml = moneyLineScene.Instantiate<MoneyLine>()
	#Vector2 goToHeight = new Vector2(1641, height)
	#ml.GlobalPosition = goToHeight
	#AddChild(ml)
	#return ml


#func TriggerCard(CardPath : String) -> bool:
	#return Rufus.SpawnObject(CardPath)

func SetPauseGame(isPaused : bool):
	for Rufus in Rufuses:
		Rufus.process_mode =  PROCESS_MODE_DISABLED if isPaused else PROCESS_MODE_INHERIT
	for node in get_tree().get_nodes_in_group("PhysicsObjects"):
		if(node is RigidBody2D):
			var rigid = node as RigidBody2D
			rigid.Freeze = isPaused
		
		##pause placed objects
		#if (node is PhysicsObject):
			#var po = node as PhysicsObject
			#if (po.rigids.Count > 0):
			#
				#if (po.isHeld):
					#continue
				#for rigid in po.rigids:
					#if (rigid is physics_body_RigidBody):
						#var spclRigid = rigid as physics_body_RigidBody
						#if (spclRigid.Static):
							#continue
						#rigid.Freeze = isPaused

func _process(_delta):
	#if (musicPlayer.VolumeDb < -20):
		#musicPlayer.VolumeDb += 2 * delta
	for Rufus in Rufuses:
		if (Rufus.global_position.y > GameManager.loseHeight):
			if musicPlayer:
				musicPlayer.volume_db = -15
				musicPlayer.stream = load("res://Assets/Sounds/GameOver.wav")
				musicPlayer.play()
		
			Rufus.Despawn()
			Rufus = null
			#var ps = load("res://Scenes/game_over.tscn")
			#var inst = ps.instantiate()
			#inst.AddToGroup("PhysicsObjects")
			#Camera.GetNode("CanvasLayer").AddChild(inst)
	
	UpdateScore()
	
	if (Input.is_action_just_pressed("FullScreenToggle")):
		var mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(mode)
		#PlayerPrefs.DeleteAll()

	#if (Rufus!=null && Rufus.Position.Y < moneyLineHeight):
		#moneyLineHeight -= 2000
		##SpawnMoneyLine(moneyLineHeight).PlayDing()
		#UpdateMoney(25)


		

	

func CanBuy(speculatedCost : int) -> bool:
	if (speculatedCost == 0):
		return true
	#print(speculatedCost + " | " + moneyOwned)
	return moneyOwned >= speculatedCost


func UpdateMoney(amount : int) -> bool:
	moneyOwned += amount
	if(moneyOwned < 0):
		moneyOwned = 0
		#moneyLabel.Text =str(moneyOwned)
		return false
	#moneyLabel.Text = str(moneyOwned)
	return true


func UpdateScore():
	#if (Rufus!=null && ceili(Rufus.GlobalPosition.Y)<score):
		#score = ceili(Rufus.GlobalPosition.Y)
		#DeckManager.Instance.scoreLabel.Text = "Score: " + (-score-169).ToString()
	
	if(score < highScore):
		highScore = score
		#DeckManager.Instance.highScoreLabel.Text = "High Score: " + (-highScore-169).ToString()
		#PlayerPrefs.SetInt("HighScore", highScore)
	



func AwardMoney():
	UpdateMoney(25)
	var ps = load("res://Scenes/money_line.tscn")
	var newLine = ps.instantiate()
	var newHeight : Vector2 = Vector2(0, -120)
	newHeight.y = (newHeight.y - 2000)
	newLine.GlobalPosition = newHeight
	get_parent().add_child.call_deferred(newLine)
