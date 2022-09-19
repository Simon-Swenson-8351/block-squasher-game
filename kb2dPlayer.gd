extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2.ZERO
const velocityMax = Vector2(1000.0, 1000.0)
export var gravity = 98.0
export var xAcceleration = 1000.0
export var xDeceleration = 2000.0
var points = 0

var relativeSnapVec = Vector2(0.0, 64.0)

var prevIsOnFloor = false
var isOnFloorCount = 0

var collidingBlocks = []
var collidingBlocksMutex = Mutex.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var input_fired = false
	var curIsOnFloor = is_on_floor()
	if(curIsOnFloor && !prevIsOnFloor):
		isOnFloorCount += 1
	if(!curIsOnFloor):
		velocity[1] += gravity * delta
	if(curIsOnFloor && isOnFloorCount > 1): # have to account for the initial platform
		# game's over
		velocity = Vector2.ZERO
		set_high_score() 
	else:
		input_fired = handle_input(delta)
	handle_screen_edge_movement()
	if(!input_fired):
		decelerate_x(delta)
	if(position.y > -280.0):
		handle_squishes()

	get_node("%Label").text = "Points: " + String(points)

	var moveResult = move_and_slide_with_snap(velocity, relativeSnapVec, Vector2.UP, true)
	
	prevIsOnFloor = curIsOnFloor

func _on_Area2D_body_entered(body):
	if(body.is_in_group("robot-guy")):
		collidingBlocksMutex.lock()
		collidingBlocks.append(body.get_instance_id())
		collidingBlocksMutex.unlock()

func _on_Area2D_body_exited(body):
	if(body.is_in_group("robot-guy")):
		collidingBlocksMutex.lock()
		var i = collidingBlocks.find(body.get_instance_id())
		if(i >= 0):
			collidingBlocks.remove(i)
		collidingBlocksMutex.unlock()


func handle_input(delta):
	var result = false;
	if(Input.is_key_pressed(KEY_LEFT)):
		velocity[0] -= xAcceleration * delta
		if(velocity[0] < -velocityMax[0]):
			velocity[0] = -velocityMax[0]
		result = true
	if(Input.is_key_pressed(KEY_RIGHT)):
		velocity[0] += xAcceleration * delta
		if(velocity[0] > velocityMax[0]):
			velocity[0] = velocityMax[0]
		result = true
	return result

func decelerate_x(delta):
	if(velocity[0] > 0.0):
		velocity[0] -= xDeceleration * delta
		if(velocity[0] < 0.0):
			velocity[0] = 0.0
	elif(velocity[0] < 0.0):
		velocity[0] += xDeceleration * delta
		if(velocity[0] > 0.0):
			velocity[0] = 0.0
			
func handle_squishes():
	collidingBlocksMutex.lock()
	var toRemove = Array()
	for i in range(0, collidingBlocks.size()):
		var collidingBlockId = collidingBlocks[i]
		var collidingBlock = instance_from_id(collidingBlockId)
		if collidingBlock:
			collidingBlock.squish()
		else:
			# can't remove in here or the loop guard becomes invalid
			toRemove.append(collidingBlockId)
	for i in toRemove:
		collidingBlocks.remove(i)
	collidingBlocksMutex.unlock()
			
func set_high_score():
	if(points > $"/root/Global".highScore):
		$"/root/Global".highScore = points
		
func handle_screen_edge_movement():
	var cameraNode = get_parent().get_node("Camera2D")
	var viewportRect = get_viewport_rect()
	var camTopLeft = cameraNode.get_camera_screen_center() - viewportRect.size / 2
	if(position.x < camTopLeft.x):
		position.x = camTopLeft.x
		velocity.x = 0
	elif(position.x > camTopLeft.x + viewportRect.size.x):
		position.x = camTopLeft.x + viewportRect.size.x
		velocity.x = 0
