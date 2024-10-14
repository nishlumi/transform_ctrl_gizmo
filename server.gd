class_name TransformCtrlGizmoServer
extends Node3D

#---if you want to change tscn, change .tscn name.
#var gizmo_template = preload("res://addons/transform_ctrl_gizmo/gizmo_template2.tscn")
#var gizmo_template = preload("res://addons/transform_ctrl_gizmo/gizmo_buttonform_template1.tscn")
#var gizmo_template = preload("res://addons/transform_ctrl_gizmo/gizmo_template1.tscn")
var gizmo_template = null
const gizmo_template_path: String = "res://addons/transform_ctrl_gizmo/"

@export_enum("gizmo_template1","gizmo_template2","gizmo_buttonform_template1") var gizmo_template_name: String = "gizmo_template2"
#---Gizmo tscn
@export var controller: TCGizmoTop
#---target node to operate
@export var target: Node3D = null
#---Camera node
@export var MainCamera: Camera3D
#---enable flag to detect a target node
@export var enable_detect: bool = true
#---child collision layer
@export_range(1,20) var child_collision_layer: int
#---space is global ? or self ?
@export var is_global: bool = false

@export var move_speed: float = 2
@export var rotate_speed: float = 1000
@export var scale_speed: float = 0.05

#---Gizmo mode
enum TCGizmoMode {FindTarget = 0, MoveTarget = 1, MoveWaitTarget = 2}
@onready var gizmode: TCGizmoMode = TCGizmoMode.FindTarget;
var bk_move_speed: float = 2
var bk_rotate_speed: float = 1000
var bk_scale_speed: float = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var templatepath = gizmo_template_path + gizmo_template_name + ".tscn"
	gizmo_template = load(templatepath)
	if enable_detect == true:
		controller = gizmo_template.instantiate()
		controller.visible = false
		controller.current_camera = MainCamera
		
		var cnt = get_tree().root.get_child_count()
		get_tree().root.get_child(cnt-1).add_child.call_deferred(controller)
	
	if MainCamera == null:
		MainCamera = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if move_speed != bk_move_speed:
		controller.move_speed = move_speed
		bk_move_speed = move_speed
	if rotate_speed != bk_rotate_speed:
		controller.rotate_speed = rotate_speed
		bk_rotate_speed = rotate_speed
	if scale_speed != bk_scale_speed:
		controller.scale_speed = scale_speed
		bk_scale_speed = scale_speed



func _input(event: InputEvent) -> void:
	if enable_detect != true:
		return
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			#---Start drag Gizmo
			if event.pressed:
				
				#---Moving mouse
				var curMousePos = event.position
				#---Detect Target object to move, or waiting target to move.
				var space_state = get_world_3d().get_direct_space_state()
				var from = MainCamera.project_ray_origin(curMousePos)
				var to = from + MainCamera.project_ray_normal(curMousePos) * 1000.0
				#---set from position and to position of ray of Camera3D
				var rayq = PhysicsRayQueryParameters3D.new()
				rayq.from = from
				rayq.to = to
				
				#print("gizmode=",gizmode)
				#if gizmode == TCGizmoMode.MoveTarget:
				#rayq.collision_mask = 1 << (child_collision_layer - 1)
				rayq.hit_from_inside = true
				#print(rayq.collision_mask)
				
				var ishit_finalcheck = true
				
				var result = space_state.intersect_ray(rayq)
				if "collider" in result:
					#---pattern
					# 1: Node3D
					#      -> StaticBody3D                     <== detect
					#           -> Collision****3D  
					# 2: Node3D (geometry) 's "use collision"  <== detect
					# 
					var rcoll = result.collider  # >>StaticBody3D<< - CollisionObject3D
					var collparent = rcoll.get_parent_node_3d()
					print(rcoll.name, "<--", collparent.name)
					
					#---collider object is same with current, skip function.
					if controller.target != null:
						if checkCurrentTargetSameAs(collparent):
							#---if waiting object to move by gizmo ?
							print("same objet hit...")
							if controller.visible == true:
								ishit_finalcheck = false
					
					#---check parent of hit object has TransformCtrlGizmoReceiver ?
					if check_TCGizmo(collparent, rcoll):
						print("new object hit!")
					else:
						#---hit object own has TransformCtrlGizmoReceiver ?
						if check_TCGizmo(rcoll, rcoll):
							print("new object hit!")
						else:
							ishit_finalcheck = false
						
					print("receive target is clicking.")
				else:
					ishit_finalcheck = false
				
				#---first ray not hit, hit but non target Node type ?
				if !ishit_finalcheck:
					var secondresult = controller.check_collision(from, to, child_collision_layer)
					if ("collider" in secondresult):
						#---hit as the object with gizmo
						var scndrcoll = secondresult.collider
						var scndcollparent = scndrcoll.get_parent_node_3d()
						print(scndrcoll.name, "<--", scndcollparent.name)
						#---check already shown gizmo. wheather it click the gizmo?
						if (scndcollparent is TCGizmoChild) or (scndcollparent is TCGizmoBtnFormChild):
							#---that object is really target ???
							print("TCGizmoChild is active!")
							controller.unhandled_input(event,scndrcoll, scndcollparent)
							gizmode = TCGizmoMode.MoveTarget
							return
					else:
						#---1st hit object is already hitted object (no operated gizmo)
						controller.visible = false
						controller.target = null
						return
			else:
				controller.unhandled_input(event,null,null)
				#if checkCurrentTargetSameAs()
				gizmode = TCGizmoMode.MoveWaitTarget
	elif event is InputEventMouseMotion:
		if controller.is_pressing_leftbutton:
			controller.unhandled_input(event,null,null)

func check_TCGizmo(collparent, collider) -> bool:
	var ret = false
	var ishit = 0 #collparent.find_children("*","TransformCtrlGizmoSelfHost",true)
	var ishit_selfhost = 0
	var ishit_receiver = 0
	var ccld = collparent.get_children()
	var objreceiver: TransformCtrlGizmoReceiver = null
	for cc in ccld:
		if cc.name == "TransformCtrlGizmoSelfHost":
			#---node has SelfHost version ?
			ishit_selfhost = 1
		if cc.name == "TransformCtrlGizmoReceiver":
			#---node has Receiver version ?
			ishit_receiver = 1
			objreceiver = cc
	if ishit_selfhost == 0:
		#ishit = collparent.find_children("*","",true)
		if ishit_receiver > 0:
			#--- synclonize position and rotation
			if is_global:
				controller.global_position.x = collparent.global_position.x
				controller.global_position.y = collparent.global_position.y
				controller.global_position.z = collparent.global_position.z
				controller.global_position.x = collparent.global_position.x
				controller.global_position.y = collparent.global_position.y
				controller.global_position.z = collparent.global_position.z
			else:
				controller.position.x = collparent.position.x
				controller.position.y = collparent.position.y
				controller.position.z = collparent.position.z
				controller.rotation.x = collparent.rotation.x
				controller.rotation.y = collparent.rotation.y
				controller.rotation.z = collparent.rotation.z
			controller.current_camera = MainCamera
			controller.target = collparent
			controller.target_collider = collider
			controller.setup_child_collision_layer(child_collision_layer)
			controller.target_receiver = objreceiver
			controller.visible = true
			controller.setup_is_global_flag(is_global)
			controller.setup_axis_visible(objreceiver.is_x, objreceiver.is_y, objreceiver.is_z)
			controller.setup_transform_visible(objreceiver.enable_translate, objreceiver.enable_rotate, objreceiver.enable_scale)
			controller.move_speed = move_speed
			controller.rotate_speed = rotate_speed
			controller.scale_speed = scale_speed
			gizmode = TCGizmoMode.MoveWaitTarget
			ret = true
	
	return ret

func check_collision(from: Vector3, to: Vector3, layer: int) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = 1 << (layer - 1)
	var result:Dictionary = space_state.intersect_ray(query)
	return result

func checkCurrentTargetSameAs(hitobjet: Node3D) -> bool:
	if controller.target.get_instance_id() == hitobjet.get_instance_id():
		return true
	else:
		return false
