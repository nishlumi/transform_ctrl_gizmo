class_name TransformCtrlGizmoReceiver
extends Node3D

#---layer to receive (use futurely)
@export var receive_layer: int = 1
#---gizmo offset to show
@export var show_offset: Vector3 = Vector3.ZERO
#---this node execute transform?
@export var enable_translate: bool = true
@export var enable_rotate: bool = true
@export var enable_scale: bool = true

#---this node access which axis?
@export var is_x: bool = true
@export var is_y: bool = true
@export var is_z: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
