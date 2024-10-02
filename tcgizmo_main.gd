class_name TCGizmoTop
extends Node3D


signal gizmo_rotate(x:float, y:float, z:float, is_relative:bool)
signal gizmo_translate(x:float, y:float, z:float, is_relative:bool)
signal gizmo_scaling(x:float, y:float, z:float, is_relative:bool)



@export var is_relative: bool = false
@export var is_translation: bool
@export var is_rotation: bool
#@export var is_scale: bool
@export var is_selfhost: bool = false
@export var is_global: bool = false
@export var target: Node3D = null
@export var target_collider: CollisionObject3D = null
@export var current_camera: Camera3D
# show position offset
@export var show_offset: Vector3 = Vector3.ZERO
@export var target_receiver: TransformCtrlGizmoReceiver
@export var move_speed: float = 2
@export var rotate_speed: float = 1000
@export var scale_speed: float = 10

var savemat = []

var last_mouse_pos = Vector2()
var last_mouse_pos3 = Vector3()
var last_target_collision_layer: int

var gizmo_inner_collision_layer: int
var is_pressing_leftbutton: bool
var pressing_tcgizmo: TCGizmoChild

const base_distance = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_pressing_leftbutton = false;
	#if target == null:
	#	target = get_parent_node_3d()
		
	#current_camera = %MainCamera
	setup_meshObject()

func _exit_tree() -> void:
	for m in savemat:
		m.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if !is_selfhost:
		if target != null:
			if is_global:
				position.x = target.position.x + target_receiver.show_offset.x + show_offset.x
				position.y = target.position.y + target_receiver.show_offset.y + show_offset.y
				position.z = target.position.z + target_receiver.show_offset.z + show_offset.z
				if is_pressing_leftbutton:
					#rotation = target.rotation
					rotation_degrees = Vector3.ZERO
				else:
					#---is release left button, recover gizmo rotation  to ZERO base.
					rotation_degrees = Vector3.ZERO
			else:
				position.x = target.position.x + target_receiver.show_offset.x + show_offset.x
				position.y = target.position.y + target_receiver.show_offset.y + show_offset.y
				position.z = target.position.z + target_receiver.show_offset.z + show_offset.z
				rotation = target.rotation
			
			#---change this gizmo size by distance to main camera
			var glodist = current_camera.global_position - global_position
			#print("glodist=",glodist.length())
			var basesize = (glodist.length() * 0.2)
			#print("basesize=",basesize)
			if basesize < 0.3:
				basesize = 0.3
			#if basesize > 5:
			#	basesize = basesize * 0.5
				
			scale.x = basesize
			scale.y = basesize
			scale.z = basesize
			
				
	
func setup(cam:Camera3D):
	current_camera = cam
	setup_meshObject()


func setup_meshObject():
	var colgreen = [
		Color(0, 1, 0, 1),
		Color(0, 0.7, 0, 1)
	]
	var colblue = [
		Color(0, 0, 1, 1),
		Color(0, 0, 0.7, 1)
	]
	var colred = [
		Color(1, 0, 0, 1),
		Color(0.7, 0, 0, 1)
	]
	var cs = get_children()
	for obj in cs:
		var meshobj:CSGPrimitive3D = obj
		var axisname = obj #.get_child(0)
		var axistype = obj.get_class().get_basename()
		var mat:StandardMaterial3D = StandardMaterial3D.new()
		mat.set("transparency",StandardMaterial3D.TRANSPARENCY_ALPHA)
		mat.set("shading_mode",StandardMaterial3D.SHADING_MODE_UNSHADED)
		if axistype == "CSGMesh3D":
			if axisname.axis.y == 0:
				mat.set("albedo_color",colgreen[0])
			elif axisname.axis.x == 0:
				mat.set("albedo_color",colred[0])
			elif axisname.axis.z == 0:
				mat.set("albedo_color",colblue[0])
		else:
			if axisname.axis.y == 1:
				mat.set("albedo_color",colgreen[0])
			elif axisname.axis.x == 1:
				mat.set("albedo_color",colred[0])
			elif axisname.axis.z == 1:
				mat.set("albedo_color",colblue[0])
		
		obj.basecolor = mat.get("albedo_color")
		obj.selcolor = Color(1.0, 1.0, 0, 1.0)
		savemat.append(mat)
		meshobj.material_override = mat

func setup_child_collision_layer(layer: int):
	var arr = [
		"RingY/StaticBody3D",
		"RingX/StaticBody3D",
		"RingZ/StaticBody3D",
		"PlaneXZ/StaticBody3D",
		"PlaneXY/StaticBody3D",
		"PlaneYZ/StaticBody3D",
		"StickY/StaticBody3D",
		"StickX/StaticBody3D",
		"StickZ/StaticBody3D"
	]
	for a in arr:
		var staticbody = get_node(a) as StaticBody3D
		staticbody.collision_layer = 1 << (layer - 1)
	gizmo_inner_collision_layer = layer
	
func setup_is_global_flag(flag: bool):
	var arr = [
		"RingY",
		"RingX",
		"RingZ",
		"PlaneXZ",
		"PlaneXY",
		"PlaneYZ",
		"StickY",
		"StickX",
		"StickZ"
	]
	for a in arr:
		var tcg = get_node(a) as TCGizmoChild
		tcg.is_global =  flag
	is_global = flag

func input_event(camera:Node, event:InputEvent, position:Vector3, normal:Vector3, shape_idx:int):
	pass

#---Receive input event ring
func input_event_axis(event:InputEvent, cur_position: Vector2, old_position: Vector2, clickpos: Vector3, axis: Vector3, transformType, is_global:bool):
	if target == null:
		return
	
	#last_target_collision_layer = target_collider.collision_layer
	#clear_collision_layer()
	
	var oldpos3 = last_mouse_pos3 #
	oldpos3 = current_camera.project_ray_normal(old_position)
	var curpos3 = current_camera.project_ray_normal(cur_position) #event.position)
	#var new_mouse_position = lineplane_intersect(oldpos3, curpos3, clickpos, axis)
	var curdot = oldpos3.dot(curpos3)
	
	
	var EnumTrans: Array = ["translate","rotate","scale"]
	
	#print("    click=",clickpos, " <-> curpos=", curpos3)
	
	if transformType == 0: #---translate
		var diff:Vector3
		diff = curpos3 - oldpos3
		
		var res = Vector3.ZERO
		var relXY = 0
		var istran = true
		
		res = diff * axis * curdot * move_speed
		
		#print("  translate",res)
		if istran == true:
			#target.transform = target.transform.translated_local(res)
			if is_global == true:
				target.global_translate(res)
			else:
				var rota = target.transform.basis
				var local_diff = rota.inverse() * diff
				target.translate(local_diff  * axis * curdot * move_speed)
			#print("  target=", target.name, ",  transformed position",target.position)
		
	elif transformType == 1: #---rotation
		var res = Vector3.ZERO
		var relXY = event.relative.x + event.relative.y
		var diff = curpos3 - oldpos3
		var sensitivity = rotate_speed
		
		#print("rotate=", axis, diff)
		if is_global == true:
			if axis.x == 1:
				#res.x = -target.rotation.x + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-diff.x * sensitivity))
				print(deg_to_rad(diff.x * sensitivity))
			if axis.y == 1:
				#res.y = -target.rotation.y + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-diff.y * sensitivity))
				print(deg_to_rad(diff.y * sensitivity))
			if axis.z == 1:
				#res.z = target.rotation.z + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-diff.z * sensitivity))
				print(deg_to_rad(diff.z * sensitivity))
		else:
			var rota = target.transform.basis
			var local_diff = rota.inverse() * diff
			if axis.x == 1:
				#res.x = -target.rotation.x + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-local_diff.x * sensitivity))
				print(deg_to_rad(local_diff.x * sensitivity))
			if axis.y == 1:
				#res.y = -target.rotation.y + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-local_diff.y * sensitivity))
				print(deg_to_rad(local_diff.y * sensitivity))
			if axis.z == 1:
				#res.z = target.rotation.z + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-local_diff.z * sensitivity))
				print(deg_to_rad(local_diff.z * sensitivity))
		
		
		
		
		#target.transform = target.transform.rotated_local(axis, ) #relXY * 0.01)
		
	#print(" ")
	last_mouse_pos3 = curpos3

func unhandled_input(event: InputEvent, hitobject, hitparent):
	'''
	Operate children StaticBody3D and an Axis from this(parent) node.
	'''
	if !current_camera:
		return
	if visible == false:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				#---click hold the this axis gizmo
				pressing_tcgizmo = hitparent
				is_pressing_leftbutton = event.pressed
				last_mouse_pos = event.position
				
			else:
				#---release this axis gizmo
				if !pressing_tcgizmo:
					return
				pressing_tcgizmo.change_state_this_axis(event)
			is_pressing_leftbutton = event.pressed
	elif  event is InputEventMouseMotion:
		if !pressing_tcgizmo:
			return
		if is_pressing_leftbutton:
			var mouse_pos = event.position
			
			#---directly call own input_event_axis event
			#   with child property (do not use child node's _input event.
			# TODO: must change the child node's mesh state 
			pressing_tcgizmo.change_state_this_axis(event)
			input_event_axis(event, mouse_pos, last_mouse_pos, Vector3.ZERO, pressing_tcgizmo.axis, pressing_tcgizmo.TransformType, pressing_tcgizmo.is_global)
			last_mouse_pos = mouse_pos
			
func check_collision(from: Vector3, to: Vector3, layer: int) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = 1 << (layer - 1)
	var result:Dictionary = space_state.intersect_ray(query)
	return result
	
func release_event_axis(axis: Vector3):
	target_collider.collision_layer = last_target_collision_layer
	print("release=",target_collider.collision_layer)
	
	
func _emit_gizmo_rotate(x, y, z) -> void:
	gizmo_rotate.emit(x, y, z, is_relative)

#=================================================================
# Vector functions
#=================================================================
func magnitude_in_direction(vector: Vector3, direction: Vector3, is_nomalized: bool = true):
	if (is_nomalized):
		direction.normalized()
	
	return vector.dot(direction)

func lineplane_distance(linepoint: Vector3, linevec: Vector3, planepoint: Vector3, planenormal: Vector3):
	var planeline_sa = planepoint - linepoint
	var dotnum = planeline_sa.dot(planenormal)
	var dotdenominator = linevec.dot(planenormal)
	
	if (dotdenominator != 0):
		return dotnum / dotdenominator
	
	return 0

func lineplane_intersect(linepoint: Vector3, linevec: Vector3, planepoint: Vector3, planenormal: Vector3):
	var dist = lineplane_distance(linepoint, linevec, planepoint, planenormal)
	
	if (dist != 0):
		return linepoint + (linevec * dist)
	
	return Vector3.ZERO
