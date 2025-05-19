class_name VehicleTextureInfo

var name: String
var x: int
var y: int
var width: int
var height: int
var texture: Texture2D

func _init(p_name: String, p_x: int, p_y: int, p_width: int, p_height: int, p_texture: Texture2D):
	name = p_name.replace(".png", "")
	x = p_x
	y = p_y
	width = p_width
	height = p_height
	texture = p_texture
