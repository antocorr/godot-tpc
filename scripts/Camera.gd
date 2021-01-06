extends Camera

# class member variables go here, for example:
export var distance = 4.0
export var height = 2.0
export (NodePath) var targetNode
export var autoturn_ray_aperture = 25
export var autoturn_speed = 50
var collision_exception = []
var zlocked = null
var ztarget = null
var autocam = true
onready var camerapos = get_parent().get_node("camerapos")


func _ready():
	targetNode = get_node(targetNode)
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
	set_as_toplevel(true)
	$CameraTween.connect("tween_all_completed", self, "restore_autocam")
func restore_autocam():
	autocam = true
func reset_view():
	#var pos = (targetNode.get_global_transform().origin - player_pos   ) 
	#pos = targetNode.get_global_transform().origin - pos
	#pos.y += height
	autocam = false
	yield(get_tree().create_timer(0.5), "timeout")
	autocam = true
	#var pos = get_parent().get_node("camerapos").get_global_transform().origin
	#pos.y += height / 2
	#var rot = get_parent().get_node("camerapos").get_global_transform().basis.get_euler()
	#rot.x = rotation_degrees.x
	#$cameraTween.interpolate_property(self, "translation", translation, pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)		
	#$cameraTween.start()
var mouse_sens = .06
var camera_anglev=0
var mouse_tres = 80
var mousecam = 0
func _input(event):         
	if event is InputEventMouseMotion:
		var tres = mouse_tres
		if abs(event.relative.x) > 0:
				tres += abs(event.relative.x * (mouse_sens * 0.5))
		if abs(event.relative.y) > tres:
			mousecam += (-event.relative.y*mouse_sens)
			mousecam = clamp(mousecam, -90, 75)
			#mousecam = null	
	else:
		mousecam += 0
func _physics_process(dt):
	var target = targetNode.get_global_transform().origin
	ztarget = null
	if zlocked:
		ztarget = zlocked.get_node("target").get_global_transform().origin
	var pos = get_global_transform().origin
	var up = Vector3(0,1,0)
	
	var offset = pos - target
	
	offset = offset.normalized()*distance
	offset.y = height
	var delta = offset
	# Check autoturn.
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space())

	var col_left = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(autoturn_ray_aperture)).xform(delta), collision_exception)
	var col = ds.intersect_ray(target, target + delta, collision_exception)
	var col_right = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(-autoturn_ray_aperture)).xform(delta), collision_exception)

	if !col.empty():
		# If main ray was occluded, get camera closer, this is the worst case scenario.
		delta = col.position - target
	elif !col_left.empty() and col_right.empty():
		# If only left ray is occluded, turn the camera around to the right.
		delta = Basis(Vector3.UP, deg2rad(-dt * autoturn_speed)).xform(delta)
	elif col_left.empty() and !col_right.empty():
		# If only right ray is occluded, turn the camera around to the left.
		delta = Basis(Vector3.UP, deg2rad(dt  *autoturn_speed)).xform(delta)
	# Do nothing otherwise, left and right are occluded but center is not, so do not autoturn.

	# Apply lookat.
	
	#pos = target + offset
	pos = target + delta		
	if ztarget:
		#target = ztarget
		pass	
	if !autocam:
		pos = lerp(pos, get_parent().get_node("camerapos").get_global_transform().origin, 0.3)
	look_at_from_position(pos, target, up)
	if mousecam:
		rotation_degrees.x = lerp(rotation_degrees.x, mousecam, 0.3)
