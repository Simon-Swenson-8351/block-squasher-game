extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const ROBOT_GUY_SCENE = preload("res://robot-guy.tscn")
var numBlocks = 32
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var enum_accessor = ROBOT_GUY_SCENE.instance()
	var special_game_type = null
	var special_game_sampler = randf()
	if(special_game_sampler < 0.01):
		special_game_type = enum_accessor.BlockType.BOMB
	elif(special_game_sampler < 0.02):
		special_game_type = enum_accessor.BlockType.GOLD
	for i in numBlocks:
		spawnRobotGuy(special_game_type)
	
func spawnRobotGuy(special_game = null):
	var size = shape_owner_get_shape(0, 0).extents * 2
	var positionInArea = Vector2( \
		rng.randf_range(0, size.x) - size.x/2 + position.x, \
		rng.randf_range(0, size.y) - size.y/2 + position.y)

	var spawn = ROBOT_GUY_SCENE.instance()
	spawn.position = positionInArea
	if(special_game == null):
		var type_sampler = randf()
		if(type_sampler < 0.1):
			spawn.point_category = spawn.BlockType.GOLD
		elif(type_sampler < 0.35):
			spawn.point_category = spawn.BlockType.SILVER
		elif(type_sampler < 0.4):
			spawn.point_category = spawn.BlockType.BOMB
		else:
			spawn.point_category = spawn.BlockType.BRONZE
	else:
		spawn.point_category = special_game
		
	get_parent().call_deferred("add_child", spawn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
