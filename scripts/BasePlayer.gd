extends KinematicBody

export (NodePath) var camNode
onready var cam = get_node(camNode)
var position_timer = 0
var joystick = null
var joystick_enabled = false
var gravity = -9.8
var velocity = Vector3()
export var speed = 6
export var jump_speed = 6
export var acceleration = 3
export var de_acceleration = 5
onready var character = self

export var local_player_id = 1
export var action_prefix_reset_cam = "player_z_"
export var action_prefix_secondary = "player_secondary_"
export var action_prefix_left = "player_left_"
export var action_prefix_right = "player_right_"
export var action_prefix_up = "player_up_"
export var action_prefix_down = "player_down_"

func get_direction_inputs():
	var input_dir = Vector3()
	input_dir.z = Input.get_action_strength("player_down_"+ str(local_player_id)) - Input.get_action_strength("player_up_"+ str(local_player_id))
	input_dir.x = Input.get_action_strength("player_right_"+ str(local_player_id)) - Input.get_action_strength("player_left_"+ str(local_player_id))
	return input_dir

func _physics_process(delta):	
	var camera = cam.get_global_transform()
	# resetting camera based direction
	var dir = Vector3()
	var is_moving = false
	var movex = 0
	var input_dir = Vector3()
	position_timer += 1
	if joystick_enabled:
		pass
		#input_dir = emulate_input()	
	if input_dir == Vector3():	
		input_dir = get_direction_inputs()
	if input_dir.z:
		is_moving = true
		dir += camera.basis[2] * input_dir.z
	if input_dir.x:
		is_moving = true
		movex = input_dir.x
		dir += camera.basis[0] * input_dir.x		
	dir.y = 0
	dir = dir.normalized()

	velocity.y += delta * gravity
	
	var hv = velocity
	hv.y = 0
	
	var new_pos = dir * speed
	var accel = de_acceleration
	
	if (dir.dot(hv) > 0):
		accel = acceleration
		
	hv = hv.linear_interpolate(new_pos, accel * delta)
	
	velocity.x = hv.x
	velocity.z = hv.z
	var jumping = false
	if Input.is_action_just_pressed(action_prefix_reset_cam +  str(local_player_id)):
		cam.reset_view()
	#Jumping
	if Input.is_action_just_pressed(action_prefix_secondary + str(local_player_id)) and is_on_floor():
		jumping = true


	if jumping:
		velocity.y += jump_speed
	velocity = move_and_slide(velocity, Vector3(0,1,0))	
	if position_timer > 11:
			position_timer = 0	
	if is_moving and is_on_floor():
		# Rotate the player to direction
		var angle = atan2(hv.x, hv.z)
		var original_angle = angle
		var char_rot = character.get_rotation()
		char_rot.y = angle
		if movex != 0:
			#char_rot.z += 2 * movex
			pass		
			
		character.set_rotation(char_rot)
	var player_speed = hv.length() / speed
