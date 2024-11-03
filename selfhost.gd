class_name TransformCtrlGizmoSelfHost
extends Node3D

var gizmo_template = preload("res://addons/transform_ctrl_gizmo/scene/gizmo_testing_form.tscn")

@export var controller: TCGizmoTop
@export var MainCamera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#controller = gizmo_template.instantiate()
	#add_child(controller)
	setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup():
	controller = gizmo_template.instantiate()
	controller.current_camera = MainCamera
	controller.target = get_parent_node_3d()
	controller.is_selfhost = true
	add_child(controller)
