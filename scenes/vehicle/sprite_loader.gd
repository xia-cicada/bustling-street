class_name VechileSpriteLoader
extends Node
"""
从XML中加载sprite数据
"""

var vehicle_textures: Array[VehicleTextureInfo] = []

func load_from_xml(xml_path:String, texture_path:String) -> void:
	# 读取xml文件内容
	var xml_file := FileAccess.open(xml_path, FileAccess.READ)
	if not xml_file:
		push_error("Fail to load xml file from %s" % xml_path)
		return
	var xml_text := xml_file.get_as_text()
	xml_file.close()
	
	# 解析xml文件内容
	var parser := XMLParser.new()
	if parser.open_buffer(xml_text.to_utf8_buffer()) != OK:
		push_error("Fail to parse xml file")
		return
		
	var atlas_texture := load(texture_path) as Texture2D
	if not atlas_texture:
		push_error("Fail to load texture from %s" % texture_path)
		return
		
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "SubTexture":
			var texture_info := VehicleTextureInfo.new(
				parser.get_named_attribute_value_safe("name"),
				parser.get_named_attribute_value_safe("x").to_int(),
				parser.get_named_attribute_value_safe("y").to_int(),
				parser.get_named_attribute_value_safe("width").to_int(),
				parser.get_named_attribute_value_safe("height").to_int(),
				atlas_texture
			)
			vehicle_textures.append(texture_info)

func get_random_vehicle() -> VehicleTextureInfo:
	if vehicle_textures.is_empty():
		push_error("No texture founded")
		return null
	var idx = randi() % vehicle_textures.size()
	return vehicle_textures.get(idx)

func create_random_vehicle_sprite() -> Sprite2D:
	var vehicle := get_random_vehicle()
	if not vehicle:
		return null
		
	var sprite2d := Sprite2D.new()
	sprite2d.texture = vehicle.texture
	sprite2d.region_enabled = true
	sprite2d.region_rect = Rect2(vehicle.x, vehicle.y, vehicle.width, vehicle.height)
	
	return sprite2d

func get_all_vehicle_names() -> PackedStringArray:
	var names: PackedStringArray = []
	for vehicle in vehicle_textures:
		names.append(vehicle.name)
	return names

func get_vehicle_by_name(vehicle_name: String) -> VehicleTextureInfo:
	for vehicle in vehicle_textures:
		if vehicle.name == vehicle_name:
			return vehicle
	return null

func get_vehicle_count() -> int:
	return vehicle_textures.size()
