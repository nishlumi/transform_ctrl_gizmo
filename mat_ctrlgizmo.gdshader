shader_type spatial;

render_mode unshaded;

uniform vec4 color : hint_color; // インスペクターで色を指定するための変数

void fragment() {
	COLOR = color;
}
