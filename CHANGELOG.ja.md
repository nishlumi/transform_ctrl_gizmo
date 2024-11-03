# CHANGELOG

## 2024/11/03

* ギズモテンプレートの名称を変更。不要なテンプレートを移動。（gizmo_buttonform_template2 は gizmo_firework_formと名付けました。）
* シグナルを追加（ギズモに動きがあった後にイベントを接続することができます）

## 2024/10/23

* TransformCtrlGizmoServerにChild Visual Layerプロパティを追加。

## 2024/10/20

* テンプレートが「gizmo_buttonform_template2」のとき、移動の操作では操作中の軸以外は非表示になるようにした。

## 2024/10/16

* 新しい操作方法のギズモとして、「gizmo_buttonform_template2」を追加。

## 2024/10/14

* 軸を選択しても色が変わらなかったのを修正。
* Gizmo Template プロパティを追加。使用するギズモのテンプレートを選択できます。
* 新しい操作方法のギズモとして、「gizmo_buttonform_template1」を追加。

## 2024/10/03

* スケールの操作を実装。
* スケールを変更すると回転の仕方がおかしくなってしまうので、回転処理を変更。
* TransformCtrlGizmoReceiverごとにTranslate/Rotate/ScaleをON/OFFできるよう実装完了。
* X/Y/Z軸の表示をON/OFFできるよう実装。
* ソースコードを整理。

## 2024/10/02

* ギズモの操作をグローバル空間・ローカル空間で切替可能にした。

## 2024/10/01

* 操作対象のNode3DとトランスフォームギズモのCollisionが重なってもギズモを操作できるように改修。


## 2024/09/20

* トランスフォームギズモが最上位に描画されるようにした。
* （予約機能）TransformCtrlGizmoReceiverごとにTranslate/Rotate/ScaleのギズモをON/OFFできるようにプロパティを用意。
