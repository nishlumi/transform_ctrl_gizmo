class_name TCGizmoBtnFormTop
extends TCGizmoTop

var btnmove_speed: Vector3 = Vector3(0.01, 0.01, 0.01)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup_child_collision_layer(layer: int):
	var arr = [
		"PosXRight/StaticBody3D",
		"PosXLeft/StaticBody3D",
		"PosYTop/StaticBody3D",
		"PosYBottom/StaticBody3D",
		"PosZForward/StaticBody3D",
		"PosZBackward/StaticBody3D",
		"RingX/StaticBody3D",
		"RingY/StaticBody3D",
		"RingZ/StaticBody3D"
	]
	var children = get_children()
	for a: TCGizmoBtnFormChild in children:
		var staticbody = a.get_node("StaticBody3D") as StaticBody3D
		staticbody.collision_layer = 1 << (layer - 1)
	gizmo_inner_collision_layer = layer
	
func setup_is_global_flag(flag: bool):
	var arr = [
		"PosXRight",
		"PosXLeft",
		"PosYTop",
		"PosYBottom",
		"PosZForward",
		"PosZBackward",
		"RingX",
		"RingY",
		"RingZ"
	]
	var children = get_children()
	for tcg: TCGizmoBtnFormChild in children:
		#var tcg = get_node(a) as TCGizmoChild
		tcg.is_global =  flag
	is_global = flag

func setup_transform_visible(is_translate: bool, is_rotate: bool, is_scale: bool):
	var arr_translate = [
		"PosXRight",
		"PosXLeft"
	]
	var arr_rotate = [
	]
	var arr_scale = [
	]
	var children = get_children()
	for tcg: TCGizmoBtnFormChild in children:
		if tcg.TransformType == TCGizmoBtnFormChild.TransformOperateType.Translate:
			tcg.visible = is_translate
			if (tcg.axis.x != 0):
				if is_x == false:
					tcg.visible = is_x
			if  (tcg.axis.y != 0):
				if is_y == false:
					tcg.visible = is_y
			if  (tcg.axis.z != 0):
				if is_z == false:
					tcg.visible = is_z
		elif tcg.TransformType == TCGizmoBtnFormChild.TransformOperateType.Rotate:
			tcg.visible = is_rotate
			if  ((tcg.name == "RingX") and (is_x == false)):
				tcg.visible = is_x
			if  ((tcg.name == "RingY") and (is_y == false)):
				tcg.visible = is_y
			if  ((tcg.name == "RingZ") and (is_z == false)):
				tcg.visible = is_z
		elif tcg.TransformType == TCGizmoBtnFormChild.TransformOperateType.Scale:
			tcg.visible = is_scale
			if  ((tcg.name == "BoxX") and (is_x == false)):
				tcg.visible = is_x
			if  ((tcg.name == "BoxY") and (is_y == false)):
				tcg.visible = is_y
			if ((tcg.name == "BoxZ") and (is_z == false)):
				tcg.visible = is_z
	
	is_translation = is_translate
	is_rotation = is_rotate
	is_scaling = is_scale

func setup_axis_visible(x: bool, y: bool, z: bool):
	is_x = x
	is_y = y
	is_z = z

func each_axis_on_pressing(type, is_global:bool, axis: Vector3, is_pressed: bool):
	if target == null:
		return
	
	if type == TransformOperateType.Translate:
		var offset = btnmove_speed * axis
		if is_global == true:
			target.transform = target.transform.translated(offset)
		else:
			target.transform = target.transform.translated_local(offset)
			
			
#---Receive input event ring
func input_event_axis(event:InputEvent, cur_position: Vector2, old_position: Vector2, clickpos: Vector3, axis: Vector3, transformType, is_global:bool):
	if target == null:
		return
	
	#last_target_collision_layer = target_collider.collision_layer
	#clear_collision_layer()
	var relXY = event.relative.x + event.relative.y
	
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
	
	if transformType == TransformOperateType.Rotate: #---rotation
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

func release_event_axis2(type, is_global: bool, axis: Vector3):
	target_collider.collision_layer = last_target_collision_layer
	print("release=",target_collider.collision_layer)

	
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
				if is_pressing_leftbutton == false:
					#---change once when state is false.
					pressing_tcgizmo.change_state_this_axis(event)
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
		var mouse_pos = event.position
		
		print("each_axis_on_pressing=",pressing_tcgizmo.axis)
		if is_pressing_leftbutton:
			if pressing_tcgizmo.TransformType == TransformOperateType.Translate:
				each_axis_on_pressing(pressing_tcgizmo.TransformType, pressing_tcgizmo.is_global, pressing_tcgizmo.axis, is_pressing_leftbutton)
			elif pressing_tcgizmo.TransformType == TransformOperateType.Rotate:
				input_event_axis(event, mouse_pos, last_mouse_pos, Vector3.ZERO, pressing_tcgizmo.axis, pressing_tcgizmo.TransformType, pressing_tcgizmo.is_global)
			
			last_mouse_pos = mouse_pos
