class_name TCGizmoBtnFormChild
extends Node3D

enum TransformOperateType{Translate = 0, Rotate = 1, Scale = 2}

@export var axis: Vector3
@export var is_global: bool = false
@export var TransformType: TransformOperateType
@export var basecolor: Color
@export var selcolor: Color

var is_transformtype: String
var old_position: Vector3
var is_pressed: bool
var old_pressed: bool
var old_mousepos: Vector2

var clickpos: Vector3


#---fire trigger input event Ring object
signal input_event_axis(event:InputEvent, position, old_position, clickpos:Vector3, axis: Vector3, operate_type, is_global:bool)
signal pressing_this_axis(type: TransformOperateType, is_global:bool, axis: Vector3, is_pressed: bool)
signal release_this_axis(type: TransformOperateType, is_global:bool, axis: Vector3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func input(event: InputEvent) -> void:
	var tcgpar = get_parent_node_3d()
	var grandpar = tcgpar.get_parent_node_3d()
	
	if is_pressed:
		if TransformType == TransformOperateType.Rotate: #---rotation
			var meshobj = self
			#print(meshobj)
			mainbody(event, meshobj, "rotation")
			is_pressed = event.pressed
		elif TransformType == TransformOperateType.Translate: #---translation
			var meshobj = self
			mainbody(event, meshobj, "translate")
			is_pressed = event.pressed
					
	if (event is InputEventMouseButton):
		#---Moving mouse
		var curcam = get_parent_node_3d().current_camera
		if curcam == null:
			return
		var curMousePos = event.position
		var space_state = get_world_3d().get_direct_space_state()
		var from = curcam.project_ray_origin(curMousePos)
		var to = from + curcam.project_ray_normal(curMousePos) * 1000.0
		#---set from position and to position of ray of Camera3D
		var rayq = PhysicsRayQueryParameters3D.new()
		rayq.from = from
		rayq.to = to
		var result = space_state.intersect_ray(rayq)
		if "collider" in result:
			var rcoll = result.collider  #CollisionObject3D
			#var collparent:Node3D = rcoll.get_parent_node_3d()
			#var collgranpa = collparent.get_parent_node_3d().get_parent_node_3d()
			#print("***hitted= ",rcoll.name)
			#print("  ", collparent)
			#print("    ", collgranpa)
			#print(result)
			
			clickpos = result.position
			
			if rcoll.name == name:
				#---hitted node and this node name is same
				if TransformType == TransformOperateType.Rotate: #---rotation
					#var meshobj = self
					
					#print(meshobj)
					mainbody(event, [self], "rotation")
					is_pressed = event.pressed
					old_mousepos = event.position
			elif rcoll.get_parent_node_3d().name == name:
				if TransformType == TransformOperateType.Rotate: #---rotation
					var meshobj = self
					#print(meshobj)
					mainbody(event, meshobj, "rotation")
					is_pressed = event.pressed
					old_mousepos = event.position
				elif TransformType == TransformOperateType.Translate: #---translation
					var meshobj = self
					mainbody(event, meshobj, "translate")
					is_pressed = event.pressed
					old_mousepos = event.position
			else:
				self.material_overlay.set("albedo_color",basecolor)
				#toggle_otheraxis_visible(self,true)
				is_pressed = false
				is_transformtype = ""
				release_this_axis.emit(TransformType, axis)
			
				
		else:
			self.material_overlay.set("albedo_color",basecolor)
			toggle_otheraxis_visible(self,true)
			is_pressed = false
			is_transformtype = ""
			release_this_axis.emit(TransformType, axis)

func mainbody(event, meshobj: Array, typestr: String = ""):
	if event is InputEventMouseButton:
		var mouseev: InputEventMouseButton = event
		
		#---Grab target axis UI
		if mouseev.button_index == MOUSE_BUTTON_LEFT:
			is_pressed = mouseev.pressed
			#print(is_pressed)
			
			#---start transform
			if mouseev.pressed:
				pressing_this_axis.emit(TransformType, axis, is_pressed)
				for mesh in meshobj:
					mesh.material_overlay.set("albedo_color",selcolor)
				#toggle_otheraxis_visible(meshobj[0].get_parent_node_3d(),false)
				is_transformtype = typestr
				print("---start ",typestr)
				print(name)
			else:
				#---end transform
				release_this_axis.emit(TransformType, is_global, axis)
				for mesh in meshobj:
					mesh.material_overlay.set("albedo_color",basecolor)
				#toggle_otheraxis_visible(meshobj[0].get_parent_node_3d(),true)
				is_transformtype = ""
				print("---end ")
				
func change_state_this_axis(event):
	var children = self.get_children()
	var meshs = []
	for child in children:
		if child is CSGPrimitive3D:
			meshs.append(child)
	if TransformType == TransformOperateType.Rotate:
		mainbody(event,meshs,"rotation")
	elif TransformType == TransformOperateType.Translate:
		mainbody(event,meshs,"translate")
	elif TransformType == TransformOperateType.Scale:
		mainbody(event,meshs,"scale")

func on_pressing_other_axis(otheraxis: Vector3, is_pressed: bool):
	if otheraxis != axis:
		var colsha: CollisionShape3D = get_node("CollisionShape3D")
		colsha.disabled = is_pressed

func toggle_otheraxis_visible(meobj:Node3D,flag: bool):
	#var nametype = meobj.name.substr(0,meobj.name.length())
	#---namely: TCGizmo node.
	var parobj: TCGizmoBtnFormTop = meobj.get_parent_node_3d()
	#---namely: RingY, PlaneXY, etc...
	var cs = parobj.get_children()
	
	for obj: TCGizmoBtnFormChild in cs:
		var ishit = true
		var finalflag: bool = flag

		#=== parent settings ===========================================================
		#---each transform type enable/disable transform type
		if (parobj.is_translation == false):
			if (obj.TransformType == TransformOperateType.Translate):
				ishit = false
		if (parobj.is_rotation == false):
			if (obj.TransformType == TransformOperateType.Rotate):
				ishit = false
		if (parobj.is_scaling == false):
			if (obj.TransformType == TransformOperateType.Scale):
				ishit = false
		
		#---each axis enable/disable transform type
		if ishit == true:
			if (parobj.is_x == false):
				if (obj.axis.x != 0) and (obj.axis.y == 0):
					ishit = false
			if (parobj.is_y == false):
				if (obj.axis.y != 0) and (obj.axis.z == 0):
					ishit = false
			if (parobj.is_z == false):
				if (obj.axis.z != 0) and (obj.axis.x == 0):
					ishit = false
		"""
		if (parobj.is_x == false) or (parobj.is_y == false) or (parobj.is_z == false):
			if (obj.TransformType == TransformOperateType.Translate):
				ishit = false
			if (obj.TransformType == TransformOperateType.Rotate):
				ishit = false
			if (obj.TransformType == TransformOperateType.Scale):
				ishit = false
		"""

		#=== current grab axis =======================================================
		#---an axis other than this axis
		if ishit == true:
			if axis.x != 0:
				if (obj.axis.x == 0):
					ishit = false
			if axis.y != 0:
				if (obj.axis.y == 0):
					ishit = false
			if axis.z != 0:
				if (obj.axis.z == 0):
					ishit = false
			"""
			if axis.x == 0:
				if (obj.axis.x != 0) and (obj.axis.y == 0):
					ishit = false
			if axis.y == 0:
				if (obj.axis.y != 0) and (obj.axis.z == 0):
					ishit = false
			if axis.z == 0:
				if (obj.axis.z != 0) and (obj.axis.x == 0):
					ishit = false
			"""

		#---loop child same as this node transformtype
		if TransformType == obj.TransformType:
			if parobj.is_x == false:
				if obj.axis.x != 0:
					ishit = false
					finalflag = false
			
			if parobj.is_y == false:
				if obj.axis.y != 0:
					ishit = false
					finalflag = false
			
			if parobj.is_z == false:
				if obj.axis.z != 0:
					ishit = false
					finalflag = false
			
		#---final check
		
		
		if ishit:
			if obj.TransformType == TransformType:
				obj.visible = true
			else:
				obj.visible = finalflag
		else:
			obj.visible = finalflag
		
