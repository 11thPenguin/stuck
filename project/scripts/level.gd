extends TileMap

signal level_loaded

export(int) var GLUCKS = 0


func _ready() :
	emit_signal("level_loaded", self)
