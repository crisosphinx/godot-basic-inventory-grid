extends ScrollContainer


func _ready() -> void:
	minimum_size_changed.connect(_on_minimum_size_changed)
	resized.connect(_resized)


func _on_minimum_size_changed() -> void:
	var _tmp: Vector2 = size
	print("minimum_size_changed: x-> %d, y-> %d" % [_tmp.x, _tmp.y])


func _resized() -> void:
	print("resized: %d" % size)
