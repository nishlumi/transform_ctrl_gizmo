# CHANGELOG

## 2024/10/20

* When the template is "gizmo_buttonform_template2", all axes except the one being operated are hidden during movement operations.

## 2024/10/16

* Added "gizmo_buttonform_template2" as a new operation gizmo.


## 2024/10/14

* Fixed the issue where the color did not change when selecting an axis.
* Added Gizmo Template property. You can select the gizmo template to use.
* Added "gizmo_buttonform_template1" as a new operation gizmo.

## 2024/10/03

* Implemented scale operation.
* Changed rotation processing because changing scale causes strange rotation.
* Implemented to turn Translate/Rotate/Scale on/off for each TransformCtrlGizmoReceiver.
* Implemented to turn X/Y/Z axis display on/off.

## 2024/10/02

* Gizmo operations can now be switched between global and local space.

## 2024/10/01

* Modified so that the gizmo can be operated even if the target Node3D and the collision of the transform gizmo overlap.

## 2024/09/20

* Transform gizmos are now drawn at the top level.
* (Reserved feature) Properties are provided to allow the Translate/Rotate/Scale gizmos to be turned on/off for each TransformCtrlGizmoReceiver.