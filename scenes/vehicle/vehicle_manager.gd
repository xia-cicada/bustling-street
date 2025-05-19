class_name VehicleManager
extends Node

var sprite_loader :VechileSpriteLoader
var active_vehicles: Array[Sprite2D] = []

@export var max_vehicles: int = 30
@export var spawn_rate: float = 0.5
@export var spawn_area: Rect2:
	set(value):
		spawn_area = value
	get:
		var viewport := get_viewport()
		if viewport:
			var viewport_size := viewport.get_visible_rect().size
			return Rect2(0, viewport_size.y * 0.1, viewport_size.x, viewport_size.y * 0.9)
		return Rect2(0, 100, 1000, 500)
@export var min_speed: float = 50.0
@export var max_speed: float = 200.0
@export var spawn_enable: bool = true

func _ready() -> void:
	sprite_loader = VechileSpriteLoader.new()
	sprite_loader.load_from_xml(
		"res://assets/graphics/spritesheet_cars.xml", 
		"res://assets/graphics/spritesheet_cars.png"
	)
	
	print("Loaded %d vehicle types" % sprite_loader.get_vehicle_count())
	print("Available vehicles: ", sprite_loader.get_all_vehicle_names())
	
	if spawn_enable:
		$SpawnTimer.wait_time = 1.0 / spawn_rate
		$SpawnTimer.start()

func _process(delta: float) -> void:
	for vehicle in active_vehicles:
		vehicle.position.x += vehicle.get_meta("speed") * delta
		
		# 移出屏幕的车辆回收
		if vehicle.position.x > spawn_area.end.x + 100:
			remove_vehicle(vehicle)

func spawn_vehicle() -> void:
	if active_vehicles.size() >= max_vehicles:
		return
	
	var new_vehicle := sprite_loader.create_random_vehicle_sprite()
	if not new_vehicle:
		return
	
	# 设置初始属性
	new_vehicle.position = Vector2(
		spawn_area.position.x - 50,
		randf_range(spawn_area.position.y, spawn_area.end.y)
	)
	
	# 设置随机速度并存储为元数据
	var speed := randf_range(min_speed, max_speed)
	new_vehicle.set_meta("speed", speed)
	
	add_child(new_vehicle)
	active_vehicles.append(new_vehicle)
	
func remove_vehicle(vehicle: Sprite2D) -> void:
	active_vehicles.erase(vehicle)
	vehicle.queue_free()

func clear_all_vehicles() -> void:
	for vehicle in active_vehicles:
		vehicle.queue_free()
	active_vehicles.clear()
	
func get_vehicles_by_type(type_name: String) -> Array[Sprite2D]:
	return active_vehicles.filter(
		func(v): return v.get_meta("vehicle_type", "") == type_name
	)

func _on_spawn_timer_timeout() -> void:
	if spawn_enable:
		spawn_vehicle()
