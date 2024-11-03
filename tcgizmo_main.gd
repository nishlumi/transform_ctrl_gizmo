class_name TCGizmoTop
extends Node3D

enum TransformOperateType{Translate = 0, Rotate = 1, Scale = 2}

## The gizmo was moved
signal gizmo_translate(pos: Vector3, pos_global: Vector3)
## The gizmo was rotated
signal gizmo_rotate(rot: Vector3, rot_global: Vector3)
## The gizmo was resized
signal gizmo_scaling(sca: Vector3)

@export var is_relative: bool = false
@export var is_translation: bool
@export var is_rotation: bool
@export var is_scaling: bool
@export var is_selfhost: bool = false
@export var is_global: bool = false
@export var is_x: bool = true
@export var is_y: bool = true
@export var is_z: bool = true

@export var target: Node3D = null
@export var target_collider: CollisionObject3D = null
@export var current_camera: Camera3D
# show position offset
@export var show_offset: Vector3 = Vector3.ZERO
@export var target_receiver: TransformCtrlGizmoReceiver
@export var move_speed: float = 2
@export var rotate_speed: float = 1000
@export var scale_speed: float = 0.05

var savemat = []

var last_mouse_pos = Vector2()
var last_mouse_pos3 = Vector3()
var last_target_collision_layer: int
var last_posdiff_length: float = 0

var gizmo_inner_collision_layer: int
var is_pressing_leftbutton: bool
var pressing_tcgizmo #: TCGizmoChild

const base_distance = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_pressing_leftbutton = false;
	#if target == null:
	#	target = get_parent_node_3d()
		
	#current_camera = %MainCamera
	#setup_meshObject()

func _exit_tree() -> void:
	for m in savemat:
		m.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func __physics_process(delta: float) -> void:
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
			var basesize = (glodist.length() * 0.1)
			#print("basesize=",basesize)
			if basesize < 0.1:
				basesize = 0.1
			#if basesize > 5:
			#	basesize = basesize * 0.5
				
			scale.x = basesize
			scale.y = basesize
			scale.z = basesize
			
			
				
	
func setup(cam:Camera3D):
	current_camera = cam
	#setup_meshObject()


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
	"""var arr = [
		"RingY/StaticBody3D",
		"RingX/StaticBody3D",
		"RingZ/StaticBody3D",
		"PlaneXZ/StaticBody3D",
		"PlaneXY/StaticBody3D",
		"PlaneYZ/StaticBody3D",
		"StickY/StaticBody3D",
		"StickX/StaticBody3D",
		"StickZ/StaticBody3D",
		"ScaleCenter/StaticBody3D",
		"BoxX/StaticBody3D",
		"BoxY/StaticBody3D",
		"BoxZ/StaticBody3D"
	]"""
	var children = get_children()
	for a: TCGizmoChild in children:
		var staticbody = a.get_node("StaticBody3D") as StaticBody3D
		if staticbody != null:
			staticbody.collision_layer = 1 << (layer - 1)
		for c in a.get_children():
			if c is CSGPrimitive3D:
				if (c as CSGPrimitive3D).use_collision == true:
					(c as CSGPrimitive3D).collision_layer = 1 << (layer - 1)
	gizmo_inner_collision_layer = layer

func setup_child_visual_layer(layer: int):
	var children = get_children()
	for a in children:
		var shapes = a.get_children()
		for shape in shapes:
			if (shape is CSGBox3D) or (shape is CSGTorus3D) or (shape is CSGMesh3D) or (shape is CSGCylinder3D):
				shape.layers = 1 << (layer - 1)

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
	var children = get_children()
	for tcg: TCGizmoChild in children:
		#var tcg = get_node(a) as TCGizmoChild
		tcg.is_global =  flag
	is_global = flag

func setup_transform_visible(is_translate: bool, is_rotate: bool, is_scale: bool):
	var arr_translate = [
		"PlaneXZ",
		"PlaneXY",
		"PlaneYZ",
		"StickY",
		"StickX",
		"StickZ"
	]
	var arr_rotate = [
		"RingY",
		"RingX",
		"RingZ"
	]
	var arr_scale = [
		"ScaleCenter",
		"BoxX",
		"BoxY",
		"BoxZ"
	]
	var children = get_children()
	for tcg: TCGizmoChild in children:
		if tcg.TransformType == TCGizmoChild.TransformOperateType.Translate:
			tcg.visible = is_translate
			if (tcg.name.find("X") > -1):
				if is_x == false:
					tcg.visible = is_x
			if  (tcg.name.find("Y") > -1):
				if is_y == false:
					tcg.visible = is_y
			if  (tcg.name.find("Z") > -1):
				if is_z == false:
					tcg.visible = is_z
		elif tcg.TransformType == TCGizmoChild.TransformOperateType.Rotate:
			tcg.visible = is_rotate
			if  ((tcg.name == "RingX") and (is_x == false)):
				tcg.visible = is_x
			if  ((tcg.name == "RingY") and (is_y == false)):
				tcg.visible = is_y
			if  ((tcg.name == "RingZ") and (is_z == false)):
				tcg.visible = is_z
		elif tcg.TransformType == TCGizmoChild.TransformOperateType.Scale:
			tcg.visible = is_scale
			if  ((tcg.axis.x != 0) and (is_x == false)):
				tcg.visible = is_x
			if  ((tcg.axis.y != 0) and (is_y == false)):
				tcg.visible = is_y
			if ((tcg.axis.z != 0) and (is_z == false)):
				tcg.visible = is_z
	"""
	for a in arr_translate:
		var tcg = get_node(a) as TCGizmoChild
		tcg.visible = is_translate
		if ((a == "PlaneXZ") or (a == "PlaneXY") or (a == "StickX")):
			if is_x == false:
				tcg.visible = is_x
		if  ((a == "PlaneXY") or (a == "PlaneYZ") or (a == "StickY")):
			if is_y == false:
				tcg.visible = is_y
		if  ((a == "PlaneXZ") or (a == "PlaneYZ") or (a == "StickZ")):
			if is_z == false:
				tcg.visible = is_z
	for a in arr_rotate:
		var tcg = get_node(a) as TCGizmoChild
		tcg.visible = is_rotate
		if  ((a == "RingX") and (is_x == false)):
			tcg.visible = is_x
		if  ((a == "RingY") and (is_y == false)):
			tcg.visible = is_y
		if  ((a == "RingZ") and (is_z == false)):
			tcg.visible = is_z
	for a in arr_scale:
		var tcg = get_node(a) as TCGizmoChild
		tcg.visible = is_scale
		if  ((a == "BoxX") and (is_x == false)):
			tcg.visible = is_x
		if  ((a == "BoxY") and (is_y == false)):
			tcg.visible = is_y
		if ((a == "BoxZ") and (is_z == false)):
			tcg.visible = is_z
	"""
	is_translation = is_translate
	is_rotation = is_rotate
	is_scaling = is_scale

func setup_axis_visible(x: bool, y: bool, z: bool):
	is_x = x
	is_y = y
	is_z = z
	
## To find MeshInstance3D recursively
func get_all_mesh_instances(node: Node) -> Array:
	var mesh_instances = []

	if (node is MeshInstance3D) or (node is VisualInstance3D):
		if !(node.get_parent() is CSGCombiner3D):
			mesh_instances.append(node)	

	for child in node.get_children():
		mesh_instances.append_array(get_all_mesh_instances(child))

	return mesh_instances

#==========================================================================
# effective events
#==========================================================================
func input_event(camera:Node, event:InputEvent, position:Vector3, normal:Vector3, shape_idx:int):
	pass

#---Receive input event ring
func input_event_axis(event:InputEvent, cur_position: Vector2, old_position: Vector2, clickpos: Vector3, axis: Vector3, transformType, is_global:bool):
	if target == null:
		return
	
	#last_target_collision_layer = target_collider.collision_layer
	#clear_collision_layer()
	var relXY = (event.relative.x * -1) + (event.relative.y * -1)
	
	var oldpos3: Vector3 = last_mouse_pos3 #
	oldpos3 = current_camera.project_ray_normal(old_position)
	#oldpos3 = current_camera.project_local_ray_normal(old_position)
	var curpos3: Vector3 = current_camera.project_ray_normal(cur_position) #event.position)
	#var curpos3: Vector3 = current_camera.project_local_ray_normal(cur_position) #event.position)

	#var new_mouse_position = lineplane_intersect(oldpos3, curpos3, clickpos, axis)
	var curdot = oldpos3.dot(curpos3)
	var posdiff_length = oldpos3.distance_to(curpos3)
	print("cur position=",cur_position,"---->",curpos3)
	
	var EnumTrans: Array = ["translate","rotate","scale"]
	
	#print("    click=",clickpos, " <-> curpos=", curpos3)
	
	if transformType == TransformOperateType.Translate: #---translate
		
		var diff:Vector3
		diff = curpos3 - oldpos3
		var diffrelative = Vector3.ZERO
		if diff.x < 0:
			diffrelative.x = -0.01 
		elif diff.x > 0:
			diffrelative.x = 0.01
		if diff.y < 0:
			diffrelative.y = -0.01 
		elif diff.y > 0:
			diffrelative.y = 0.01
		if diff.z < 0:
			diffrelative.z = -0.01 
		elif diff.z > 0:
			diffrelative.z = 0.01
		
		var res = Vector3.ZERO
		var istran = true
		
		var xyz = 000
		if (axis.x == 1) and (axis.y == 1):
			xyz = 110
		elif (axis.y == 1) and (axis.z == 1):
			xyz = 011
		elif (axis.x == 1) and (axis.z == 1):
			xyz = 101
		
		res = diff * (axis * curdot) * move_speed
		
		print("  translate",res)
		if istran == true:
			#target.transform = target.transform.translated_local(res)
			if is_global == true:
				var parentpos = self.global_position
				target.global_translate(res)

			else:
				var parentpos = self.position
				var rota = target.transform.basis
				var local_diff = rota * (diff * move_speed)
				print("****diff=",diff)
				print("    rota.inverse=",rota.inverse(),"<--",rota)
				print("    local_diff=",local_diff)
				print("    axis=",axis)
				print("    curdot=",curdot)
				print("    result=",local_diff  * axis)
				
				
				#TODO:２方向移動の場合、event.relativeを考慮すればいい気がする・・・
				
				var direction = (target.transform.basis * Vector3(local_diff * axis)).normalized()
				direction.x *= 0.1
				direction.y *= 0.1
				direction.z *= 0.1
				print("    direction=",direction)
				#target.translate(local_diff * axis)
				#var ori = target.transform.origin
				#ori += local_diff * axis
				#target.transform.origin = ori
				if (event.relative.x != 0) and (event.relative.y != 0):
					pass
				elif (event.relative.x != 0):
					pass
				elif (event.relative.y != 0):
					pass
				target.transform = target.transform.translated_local(local_diff * axis)
				#target.transform = target.transform.translated_local(diff * axis)
				#target.transform = target.transform.translated_local(direction)
				
				
			gizmo_translate.emit(target.position,target.global_position)
			#print("  target=", target.name, ",  transformed position",target.position)
		
	elif transformType == TransformOperateType.Rotate: #---rotation
		var res = Vector3.ZERO
		
		var diff = curpos3 - oldpos3
		var sensitivity = rotate_speed
		
		#print("rotate=", axis, diff)
		if is_global == true:
			var tmprot = target.global_rotation_degrees
			if axis.x == 1:
				#res.x = -target.rotation.x + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-diff.x * sensitivity))
				tmprot.x = tmprot.x + (-diff.x * sensitivity)
				print(deg_to_rad(diff.x * sensitivity))
			if axis.y == 1:
				#res.y = -target.rotation.y + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-diff.y * sensitivity))
				tmprot.y = tmprot.y + (-diff.y * sensitivity)
				print(deg_to_rad(diff.y * sensitivity))
			if axis.z == 1:
				#res.z = target.rotation.z + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-diff.z * sensitivity))
				tmprot.z = tmprot.z + (-diff.z * sensitivity)
				print(deg_to_rad(diff.z * sensitivity))
			#target.global_rotation_degrees = tmprot

		else:
			var rota = target.transform.basis
			var local_diff = rota.inverse() * diff
			var tmprot = target.rotation_degrees
			
			var backorigin = target.transform.origin
			target.transform.origin = target.global_position
			if axis.x == 1:
				#res.x = -target.rotation.x + relXY * 0.1				
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-local_diff.x * sensitivity))
				#target.transform.basis = target.transform.basis.rotated(axis, deg_to_rad(-local_diff.x * sensitivity))
				#tmprot.x = tmprot.x + (-local_diff.x * sensitivity)
				print((local_diff.x * sensitivity))
			if axis.y == 1:
				#res.y = -target.rotation.y + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-local_diff.y * sensitivity))
				#target.transform.basis = target.transform.basis.rotated(axis, deg_to_rad(-local_diff.y * sensitivity))
				#tmprot.y = tmprot.y + (-local_diff.y * sensitivity)
				print((local_diff.y * sensitivity))
			if axis.z == 1:
				#res.z = target.rotation.z + relXY * 0.1
				target.transform = target.transform.rotated_local(axis, deg_to_rad(-local_diff.z * sensitivity))
				#target.transform.basis = target.transform.basis.rotated(axis, deg_to_rad(-local_diff.z * sensitivity))
				#tmprot.z = tmprot.z + (-local_diff.z * sensitivity)
				print((local_diff.z * sensitivity))
			#target.rotation_degrees = tmprot
			
			target.transform.origin = backorigin

		gizmo_rotate.emit(target.rotation_degrees, target.global_rotation_degrees)
	elif transformType == TransformOperateType.Scale: #---scale
		var diff = curpos3 - oldpos3
		
		print("relXY=",relXY)
		print("diff=",diff)
		print("curdot=",curdot)
		var rate = 0
		if relXY > 0:
			rate = 1
		elif relXY < 0:
			rate = -1
		
		var children = get_all_mesh_instances(target)
		var tmpscale: Vector3 = target.scale
		if children.size() > 0:
			tmpscale = children[0].scale
		
		if axis.x == 1:
			tmpscale.x = tmpscale.x + scale_speed * rate 
		if axis.y == 1:
			tmpscale.y = tmpscale.y + scale_speed * rate 
		if axis.z == 1:
			tmpscale.z = tmpscale.z + scale_speed * rate 
		
		print("tmpscale=",tmpscale)
		#target.transform = target.transform.scaled(tmpscale)
		#target.scale = tmpscale
		for child in children:
			child.scale = tmpscale
		
		#target.transform = target.transform.rotated_local(axis, ) #relXY * 0.01)

		gizmo_scaling.emit(tmpscale, false)
		
		
	last_posdiff_length = posdiff_length
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
				pressing_tcgizmo.change_state_this_axis(event)
				
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
	#target_collider.collision_layer = last_target_collision_layer
	print("release=",target_collider.collision_layer)
	

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
