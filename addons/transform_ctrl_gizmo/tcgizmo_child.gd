class_name TCGizmoChild
extends Node3D

@export var axis: Vector3
@export var is_global: bool = false
enum TransformOperateType{Translate = 0, Rotate = 1, Scale = 2}
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
signal pressing_this_axis(axis: Vector3, is_pressed: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	old_position = Vector3.ZERO
	old_mousepos = Vector2.ZERO
	is_pressed = false
	old_pressed = false
	is_transformtype = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pressing_this_axis.emit(axis, false)
	pass

func mouse_exited():
	#var ringnode = get_parent_node_3d()
	self.material_override.set("albedo_color",basecolor)
	is_pressed = false

func _input(event: InputEvent) -> void:
	var tcgpar = get_parent_node_3d()
	var grandpar = tcgpar.get_parent_node_3d()
	
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
				if TransformType == TransformOperateType.Rotate: #---rotation
					var meshobj = self
					#print(meshobj)
					mainbody(event, meshobj, "rotation")
				elif TransformType == TransformOperateType.Translate: #---translation
					var meshobj = self
					mainbody(event, meshobj, "translate")
			else:
				self.material_override.set("albedo_color",basecolor)
				#toggle_otheraxis_visible(self,true)
				is_pressed = false
				is_transformtype = ""
				
		else:
			self.material_override.set("albedo_color",basecolor)
			toggle_otheraxis_visible(self,true)
			is_pressed = false
			is_transformtype = ""
	
	elif (event is InputEventMouseMotion):
		var mousepos = event.position
		if is_pressed :
			#---fire input ring
			#print(event)
			input_event_axis.emit(event, mousepos, old_mousepos, clickpos, axis, TransformType, is_global)
		
		##print("event after position=",position)
		#old_position = position
		old_pressed = is_pressed
		
		old_mousepos = mousepos
	
	
	


func mainbody(event, meshobj, typestr: String = ""):
	if event is InputEventMouseButton:
		var mouseev: InputEventMouseButton = event
		
		#---Grab target axis UI
		if mouseev.button_index == MOUSE_BUTTON_LEFT:
			is_pressed = mouseev.pressed
			#print(is_pressed)
			
			pressing_this_axis.emit(axis, is_pressed)
			#---start transform
			if mouseev.pressed:
				meshobj.material_override.set("albedo_color",selcolor)
				toggle_otheraxis_visible(meshobj,false)
				is_transformtype = typestr
				print("---start ",typestr)
				print(name)
			else:
				#---end transform
				meshobj.material_override.set("albedo_color",basecolor)
				toggle_otheraxis_visible(meshobj,true)
				is_transformtype = ""
				print("---end ")
				

func on_pressing_other_axis(otheraxis: Vector3, is_pressed: bool):
	if otheraxis != axis:
		var colsha: CollisionShape3D = get_node("CollisionShape3D")
		colsha.disabled = is_pressed

func toggle_otheraxis_visible(meobj:Node3D,flag: bool):
	var nametype = meobj.name.substr(0,meobj.name.length())
	var parobj = meobj.get_parent_node_3d()
	var cs = parobj.get_children()
	
	for obj in cs:
		if obj.TransformType == TransformType:
			obj.visible = true
		else:
			obj.visible = flag
