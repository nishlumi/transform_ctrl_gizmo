class_name TransformCtrlGizmoServer
extends Node3D

#---if you want to change tscn, change .tscn name.
var gizmo_template = preload("res://addons/transform_ctrl_gizmo/gizmo_template2.tscn")

#---Gizmo tscn
@export var controller: TCGizmoTop
#---target node to operate
@export var target: Node3D = null
#---Camera node
@export var MainCamera: Camera3D
#---enable flag to detect a target node
@export var enable_detect: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	pass


func _input(event: InputEvent) -> void:
	if enable_detect != true:
		return
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			#---Start drag Gizmo
			if event.pressed:
		
				#---Moving mouse
				var curMousePos = event.position
				var space_state = get_world_3d().get_direct_space_state()
				var from = MainCamera.project_ray_origin(curMousePos)
				var to = from + MainCamera.project_ray_normal(curMousePos) * 1000.0
				#---set from position and to position of ray of Camera3D
				var rayq = PhysicsRayQueryParameters3D.new()
				rayq.from = from
				rayq.to = to
				var result = space_state.intersect_ray(rayq)
				if "collider" in result:
					#---pattern
					# 1: Node3D
					#      -> StaticBody3D                     <== detect
					#           -> Collision****3D  
					# 2: Node3D (geometry) 's "use collision"  <== detect
					# 
					var rcoll = result.collider  # >>StaticBody3D<< - CollisionObject3D
					var collparent:Node3D = rcoll.get_parent_node_3d()
					
					#---collider object is same with current, skip function.
					if controller.target != null:
						if controller.target == collparent:
							return
							
					#print(rcoll.name, "<--", collparent.name)
					#print(MainCamera.position - collparent.position)
					#---check parent of hit object has TransformCtrlGizmoReceiver ?
					if check_TCGizmo(collparent) == false:
						#---hit object own has TransformCtrlGizmoReceiver ?
						check_TCGizmo(rcoll)

func check_TCGizmo(collparent):
	var ret = false
	var ishit = 0 #collparent.find_children("*","TransformCtrlGizmoSelfHost",true)
	var ishit_selfhost = 0
	var ishit_receiver = 0
	var ccld = collparent.get_children()
	var objreceiver = null
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
			controller.position.x = collparent.position.x
			controller.position.y = collparent.position.y
			controller.position.z = collparent.position.z
			controller.rotation.x = collparent.rotation.x
			controller.rotation.y = collparent.rotation.y
			controller.rotation.z = collparent.rotation.z
			controller.current_camera = MainCamera
			controller.target = collparent
			controller.target_receiver = objreceiver
			controller.visible = true
			ret = true
	
	return ret

func detect_mousepos_object(position: Vector2):
	var scene_pos = MainCamera.project_ray_origin(position)
	
	var wpos = MainCamera
