# transform_ctrl_gizmo
Transform Control (Gizmo) on runtime loading for Godot Engine

![Screenshot](img/img01.png "Gizmo image")

Video：

[YouTube](https://youtu.be/58NAPNE-Y24)

## To install


1. run `git clone` this repository.

*This repository is a folder for the add-on itself.

2. Copy `addons/transform_ctrl_gizmo` directory to a game project of Godot.

    src: `[parent dir after git clone]/transform_ctrl_gizmo`

    destination: `game project dir/addons/transform_ctrl_gizmo`

3. Project menu -> Project settings -> Plugin
4. Enable status of `transform_ctrl_gizmo`

## To use

**Camera3D node**

1. Add `TransformCtrlGizmoServer` as child node
2. Attach parent Camera3D to `Main Camera` property.
3. Enable `Enable Detect` property.

**Target Nodes**

1. Add `TransformCtrlGizmoReceiver` as child node.

    **Normal 3D node** 

    2. Add `StaticBody3D` as child node.
    3. Add `CollisionShape3D` as child node of `StaticBody3D`.

    **3D node has `Use collision` property**

    2. Enable `Use collision`

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

**Enable Translate**

Enables translation.

**Enable Rotate**

Enables rotation.

**Enable Scale**

Enables scale.

**Is X**

Enables operations on the X axis.

**Is Y**

Enables operations on the Y axis.

**Is Z**

Enables operations on the Z axis.


### TransformCtrlGizmoServer

#### Properties

**Gizmo Template**

Select the name of the gizmo template you want to use.

* gizmo_basic_form - A general gizmo shape.
* gizmo_testing_form - A new shape we are currently testing.
* gizmo_firework_form - A completely new shape with a completely new way to operate.

gizmo_firework_form: Gizmo firework form
    ![gizmo_firework_form](img/img02.png "Gizmo firework form")

    If you drag the lines pointing in the X/Y/Z directions, the object will move in the direction the lines point. Unlike conventional transform handles, mouse movements are not reflected as coordinates in 3D space.
    The target object will not move unless you click and hold the mouse to move it.

**Controller**

Internal scene `TCGizmoTop`. Create automatically.

**Target**

The node detected by clicking.

**Main Camera**

Camera node to reference. If not specified, the parent node will be automatically set as the camera node during initialization.

**Child Collision Layer**

Sets the collision layer for the entire gizmo. Do not use this layer for other nodes.

**Child Visual Layer**

Sets the drawing layer for the entire gizmo. This should be a layer that is not used by other nodes.

**Is Global**

Switches the operation space between global and local.

**Move Speed**

Sets the movement speed.

**Rotate Speed**

Sets the rotation speed.

**Scale Speed**

Sets the scale speed.

#### Signals

**gizmo_changed_target(newtarget: Node, oldtarget: Node)**

This signal is sent when the gizmo's target node is changed.
newtarget - new target node
oldtarget - old target node

**gizmo_complete_translate(pos: Vector3, pos_global: Vector3)**

This signal is sent when a translation operation is performed.
pos - new position (local)
pos_global - new position (global)

**gizmo_complete_rotate(angle: Vector3, angle_global: Vector3)**

This signal is sent when a rotation operation is performed.
angle - new angle (local)
angle_global - new angle (global)

**gizmo_complete_scale(scale: Vector3)**

This signal is sent when a scale operation is performed.
scale - new scale

## Postscript

I created this add-on because I wanted a Gizmo that could move and rotate objects during runtime execution in Godot Engine.

However, it is still not functional enough.

If you can modify it, please try improving this add-on.


# Developer

NISHIWAKI(lumis)

[X(Twitter) ](https://twitter.com/lumidina)

[Mastodon](https://mstdn.jp/@lumidina)

