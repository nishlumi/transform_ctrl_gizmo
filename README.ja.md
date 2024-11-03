# transform_ctrl_gizmo

これはGodot Engineのランタイム実行時に 使える移動・回転コントロール（Gizmo）です。

![Screenshot](img/img01.png "Gizmo image")

動画：

[YouTube](https://youtu.be/58NAPNE-Y24)

## インストール

1. このリポジトリを `git clone` します。

※このリポジトリはアドオン自体のフォルダにしました。

2. このフォルダをGodotのゲームプロジェクトフォルダにコピーします。
    
    コピー元: `git clone後の親フォルダ/transform_ctrl_gizmo/`

    貼り付け先: `ゲームフォルダ/addons/transform_ctrl_gizmo`

3. Project メニュー -> Project 設定 -> プラグイン
4. `transform_ctrl_gizmo` のステータスをONにします。

## 使用方法

**Camera3D ノード**

1. 子ノードとして `TransformCtrlGizmoServer` を追加します。
2. `Main Camera` プロパティに 親のCamera3Dノードを設定します。
3. `Enable Detect` プロパティを有効にします。

**対象のノード（複数）**

1. `TransformCtrlGizmoReceiver` を子ノードとして追加します。

    **通常の3Dノード**

    2. `StaticBody3D`を子ノードとして追加します。
    3. `CollisionShape3D` を `StaticBody3D` の子ノードとして追加します。

    **`Use Collision` プロパティを持つ3Dノード**

    2. `Use collision` にチェックを入れます。

※Godotでの衝突の処理方法に準じます。

**実行時**

TransformCtrlGizmoRceiver を持つ3Dノードをクリックすると、Gizmoが表示されます。クリックを検出するため、対象のノードには衝突の機能を付ける必要があります。

GodotEngineではFBXなどの外部の3Dオブジェクトとの表示の順序がうまく動かないように思えます。

その代わりとしてTransformCtrlGizmoRceiver のプロパティに Show Offset があります。そのプロパティでgizmoの表示位置を3Dノード別にずらすことができます。


## カスタマイズ

### TransformCtrlGizmoReceiver

**Receive Layer** 

将来使う予定です。

**Show Offset**

gizmoの表示位置をずらすことができます。


**Enable Translate**

移動を有効にします。

**Enable Rotate**

回転を有効にします。

**Enable Scale**

スケールを有効にします。

**Is X**

X軸の各操作を有効にします。

**Is Y**

Y軸の各操作を有効にします。

**Is Z**

Z軸の各操作を有効にします。


### TransformCtrlGizmoServer

#### プロパティ

**Gizmo Template**

使用するギズモのテンプレート名を選択します。

* gizmo_basic_form - 一般的なギズモの図形です。
* gizmo_testing_form - 現在テストしている新しい図形です。
* gizmo_firework_form - 操作方法を一新したまったく新しい図形です。

gizmo_firework_form: ギズモ花火フォーム
    ![gizmo_firework_form](img/img02.png "Gizmo firework form")

    X/Y/Z軸それぞれの方向に向いた棒線をドラッグして動かすと、その棒線の向いた方向へと移動します。従来のトランスフォームハンドルのように、マウスの動きが3D空間の座標になって反映されることはありません。
    マウスでクリックしたままで動かさないと、対象のオブジェクトは動きません。


**Controller**

内部シーン `TCGizmoTop` です。自動的に生成されます。

**Target**

クリックして検知されたノードです。

**Main Camera**

参照するカメラノードです。未指定の場合、初期化時に自動的に親ノードをカメラノードとしてセットします。

**Enable Detect**

検出を開始します。

**Child Collision Layer**

ギズモ全体のコリジョンレイヤーを設定します。他のノードでは使わないレイヤーにしてください。

**Child Visual Layer**

ギズモ全体の描画レイヤーを設定します。他のノードでは使わないレイヤーにしてください。

**Is Global**

操作空間をグローバル・ローカルどちらかに切り替えます。

**Move Speed**

移動の速度を設定します。

**Rotate Speed**

回転の速度を設定します。

**Scale Speed**

スケールの速度を設定します。

#### シグナル

**gizmo_changed_target(newtarget: Node, oldtarget: Node)**

ギズモの対象のノードが変更されたらこのシグナルが送信されます。
newtarget - 新しい対象ノード
oldtarget - 古い対象ノード

**gizmo_complete_translate(pos: Vector3, pos_global: Vector3)**

移動の操作が行われたらこのシグナルが送信されます。
pos - 移動後の位置（ローカル）
pos_global - 移動後の位置（グローバル）

**gizmo_complete_rotate(angle: Vector3, angle_global: Vector3)**

回転の操作が行われたらこのシグナルが送信されます。
angle - 回転後の角度（ローカル）
angle_global - 回転後の角度（グローバル）

**gizmo_complete_scale(scale: Vector3)**

スケール変更の操作が行われたらこのシグナルが送信されます。
scale - 変更後のスケール


## 後記

Godot Engine でランタイム実行時にオブジェクトを移動・回転できるGizmoが欲しくてこのアドオンを作成しました。

しかしまだ機能的には足りていません。

改造できる方はぜひこのアドオンを改良してみてください。

# 開発者

NISHIWAKI(lumis)

[X(Twitter) ](https://twitter.com/lumidina)

[Mastodon](https://mstdn.jp/@lumidina)

