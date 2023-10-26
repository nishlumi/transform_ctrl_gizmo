@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("TransformCtrlGizmoReceiver", "Node3D", preload("receiver.gd"),null)
	add_custom_type("TransformCtrlGizmoServer", "Node3D", preload("server.gd"),null)
	add_custom_type("TransformCtrlGizmoSelfHost", "Node3D", preload("selfhost.gd"),null)



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
