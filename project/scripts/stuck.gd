extends Node2D

var level_active = false
var level = 0

func _ready() :
	$MainMenu.connect("play_button", self, "_on_play_button")
	$StartScreen.connect("begin_button", self, "_on_begin_button")
	$NextLevelScreen.connect("next_button", self, "_on_next_button")

	$SelectRing.bind_player($Player)


func _process(_delta) :
	if !level_active :
		return

	if Input.is_action_just_pressed("left_click") :
		$SelectRing.open()


func _on_Player_level_complete() :
	print("LEVEL %d COMPLETE!" % level)

	level_active = false
	$NextLevelScreen.visible = true


func _on_play_button() :
	print("PLAY!")
	$MainMenu.visible = false
	_load_level()


func _on_begin_button() :
	print("Begin!")
	$StartScreen.visible = false

	level_active = true


func _on_next_button() :
	print("Next!")
	$NextLevelScreen.visible = false

	level = level + 1
	_load_level()


func _load_level() :
	var curr_level = $Level.get_child(0)
	if curr_level :
		curr_level.queue_free()

	# JASNOTE: This is getting into some JAMmy fixes here.
	var level_packedscene = load("res://scenes/levels/level%d.tscn" % level)
	var new_level = level_packedscene.instance()
	new_level.connect("level_loaded", self, "_on_level_loaded")
	$Level.call_deferred("add_child", new_level)


func _on_level_loaded(level_node) :
	print("Loaded level %s!" % level_node)

	var spawn_marker = level_node.find_node("SpawnMarker")
	$Player.position = spawn_marker.position
	$Player.visible = true
	$Player.configure_glucks(level_node.GLUCKS)

	$StartScreen/LevelLabel.text = "Level %d" % (level + 1)
	$StartScreen/GoalLabel.text = "COLLECT %d UCK" % level_node.GLUCKS
	$StartScreen.visible = true
