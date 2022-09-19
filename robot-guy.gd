extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum BlockType { BRONZE, SILVER, GOLD, BOMB }
var point_category = BlockType.BRONZE
const SQUISH_MULTIPLIER = 0.1
const TOTALLY_SQUISHED_AREA = 0.1

const ROBOT_GUY_EXPLOSION_SCENE = preload("res://robot-guy-explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	$Sprite.modulate = get_color()
	
#	if(applied_force.length() > 0.1):
	if(linear_velocity.length() > 350.0):
		squish()
	
func get_color():
	if(point_category == BlockType.BRONZE):
		return Color(0.5725490196078431, 0.407843137254902, 0.0274509803921569)
	elif(point_category == BlockType.SILVER):
		return Color(0.7215686274509804, 0.7215686274509804, 0.7215686274509804)
	elif(point_category == BlockType.GOLD):
		return Color(1.0, 1.0, 0.5)
	else:
		return Color(0.1, 0.1, 0.1)
	
func get_points():
	if(point_category == BlockType.BRONZE):
		return 1
	elif(point_category == BlockType.SILVER):
		return 2
	elif(point_category == BlockType.GOLD):
		return 3
	else:
		return 1

func squish():
	var squishAxis = rotation + PI/2.0
	var newScaleModifier = Vector2(abs(cos(squishAxis)), abs(sin(squishAxis))) * SQUISH_MULTIPLIER
	var newScale = $CollisionShape2D.scale - newScaleModifier
	if(newScale.x * newScale.y <= TOTALLY_SQUISHED_AREA):
		# totally squished
		get_tree().get_root().get_node("Node2D").get_node("kb2dPlayer").points += get_points()
		var newRobotExplosion = ROBOT_GUY_EXPLOSION_SCENE.instance()
		newRobotExplosion.global_position = global_position
		if(point_category == BlockType.BOMB):
			spawn_explosion_bullets()
		get_parent().add_child(newRobotExplosion)
		queue_free()
	if(newScale.x < 0.0):
		newScale.x = 0.0
	if(newScale.y < 0.0):
		newScale.y = 0.0
	$CollisionShape2D.scale = newScale
	$Sprite.scale = newScale
	
func spawn_explosion_bullets():
	var numBullets = 72
	var bulletAngleDelta = 2 * PI / numBullets
	for i in numBullets:
		var bulletAngle = bulletAngleDelta * i
		spawn_explosion_bullet(bulletAngle)
		
func spawn_explosion_bullet(bulletAngle):
	
	var bulletRigidBody = RigidBody2D.new()
	var bulletCollisionShape = CollisionShape2D.new()
	
	var bulletShape = CircleShape2D.new()
	bulletShape.radius = 2.5
	bulletCollisionShape.shape = bulletShape
	
	var bulletIndicator = Sprite.new()
	bulletIndicator.texture = load("res://icon.png")
	bulletIndicator.scale = Vector2(5.0 / 64.0, 5.0 / 64.0)
	
	bulletRigidBody.add_child(bulletCollisionShape)
	bulletRigidBody.add_child(bulletIndicator)
	
	
	get_parent().add_child(bulletRigidBody)
	
	var bulletAngleVector = Vector2(cos(bulletAngle), sin(bulletAngle))
	
	bulletRigidBody.global_position = global_position + bulletAngleVector * 10
	bulletRigidBody.apply_impulse(Vector2.ZERO, bulletAngleVector * 1000)
	
	
