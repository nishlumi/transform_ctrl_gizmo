# transform_ctrl_gizmo
Transform Control (Gizmo) on runtime loading for Godot Engine


## To install

1. run `git clone` this repository.
1. Copy this directory to a game project of Godot.

    src: `parent dir/transform_ctrl_gizmo`

    destination: `game project dir/addons/transform_ctrl_gizmo`

2. Project menu -> Project settings -> Plugin
3. Enable status of `transform_ctrl_gizmo`

## To use

**Camera3D node**

1. Add `TransformCtrlGizmoServer` as child node
2. Attach parent Camera3D to `Main Camera` property.
3. Enable `Enable Detect` property.

**Target Nodes**

1. Add `TransformCtrlGizmoReceiver` as child node.
2. Add `StaticBody3D` as child node.
3. Add `CollisionShape3D` as child node of `StaticBody3D`.

* Please follow how Godot handles collisions.

**On execute**

 Click on the 3D node with `TransformCtrlGizmoRceiver` and the Gizmo will appear. In order to detect clicks, the target node must be equipped with a collision function.

 In GodotEngine, it seems that the display order with external 3D objects such as FBX does not work properly. 

 Instead, there is a property of TransformCtrlGizmoRceiver called Show Offset. You can use that property to shift the display position of the gizmo for each 3D node.


## Customize

### TransformCtrlGizmoReceiver

**Receive Layer** 

Use futurely.

**Show Offset**

You can shift the display position of gizmo.

### TransformCtrlGizmoServer

**Controller**

Internal scene `TCGizmoTop`. Create automatically.

**Target**

The node detected by clicking.

**Main Camera**

Camera node to reference. If not specified, the parent node will be automatically set as the camera node during initialization.

**Enable Detect**

Start detection.



## Postscript

I created this add-on because I wanted a Gizmo that could move and rotate objects during runtime execution in Godot Engine.

However, it is still not functional enough.

If you can modify it, please try improving this add-on.