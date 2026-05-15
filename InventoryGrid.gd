extends Control

## NOTE: This should really be a constant, but we are modifying this to an exported
## variable for modification / experimentation purposes only. 
@export var max_slots: int = 100

## The width and height of each item.
@export var item_size: int = 64

## Our mock inventory has 18 items out of a possible [member max_slots].
## If we multiply 
@export var item_count: int = 18
@export var column_count: int = 6 :
	set(value):
		set_column_count(value)

@export var grid_item: PackedScene

# Notes:
#
# - Set custom_minimum_size on the child of a ScrollContainer to affect its size.
#   When either the width or height (or both) are bigger than that of
#   the ScrollContainer itself, that dimension will get a scroll bar.
# - We disable horizontal scrolling via the editor since we don't need it.
#   In doing so, we also avoid this bug: https://github.com/godotengine/godot/issues/28464
#   Set horizontal_scroll_enabled if doing it through code.
# - In the editor, under Size Flags, we check the "Expand" checkbox
#   in the "Horizontal" section. This makes the grid take up all of the available
#   space within the ScrollContainer.
# - The natural width (custom_minimum_size.x) of the grid is column_count * item_size.

func _ready() -> void:
	resize_grid()
	update_slots()

func scroll_bar_width() -> int:
	return get_parent_control().get_v_scrollbar().size.x

func get_column_count() -> int:
	return column_count
	
func set_column_count(count) -> void:
	column_count = count
	resize_grid()
	update_slots()

func get_row_count() -> int:
	# Can be an annoying warning. This is useful for anyone unfamiliar with it.
	@warning_ignore("integer_division") 
	
	# Make sure we cast the result to an int, otherwise we have extra, unused vertical space
	# at the bottom of the grid.
	return int(max_slots / get_column_count())

func resize_grid() -> void:
	custom_minimum_size.x = get_column_count() * item_size
	custom_minimum_size.y = get_row_count() * item_size

func index_to_pos(index: int) -> Vector2:
	var columns: int = get_column_count()
	@warning_ignore("integer_division")
	return Vector2(int(index % columns), int(index / columns))
	
func update_slots() -> void:
	var rows: int = get_row_count()
	var columns: int = get_column_count()
	print("displaying %d rows and %d columns" % [rows, columns])
	
	for slot_index in range(0, max_slots):
		if get_child_count() - 1 < slot_index:
			# No slot here yet; need to create it.
			var _item: Control = grid_item.instantiate()
			_item.position = index_to_pos(slot_index) * item_size
			add_child(_item)
			
		var item = get_child(slot_index)
		if (item_count > slot_index):
			# This slot is occupied.
			item.texture = load("res://icon.png")
		else:
			item.texture = load("res://slot.png")
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("give_item"):
		# Give a row of items to make testing quicker.
		item_count += get_column_count()
		update_slots()
	elif event is InputEventMouseButton:
		# While not necessary in this particular example,
		# if ScrollContainer is moved within e.g. a popup,
		# the event coordinates seem to be made global,
		# so it's a good idea to ensure that they are always local.
		var mouse_pos = make_input_local(event).position
		var item_column = mouse_pos.x / item_size
		if (item_column >= get_column_count()):
			# The click is outside of us.
			return
			
		var item_row = mouse_pos.y / item_size
		if (item_row >= get_row_count()):
			# The click is outside of us.
			return
		
		var item_index = int(item_row) * get_column_count() + int(item_column)
		
		if !event.is_pressed():
			if (event.button_index == MOUSE_BUTTON_LEFT):
				item_left_clicked(item_index)
			elif (event.button_index == MOUSE_BUTTON_RIGHT):
				item_right_clicked(item_index)
		elif (event.double_click):
			item_double_clicked(item_index)
			
			
func item_left_clicked(index: int) -> void:
	print("item at index %d was left clicked" % index)


func item_right_clicked(index: int) -> void:
	print("item at index %d was right clicked" % index)


func item_double_clicked(index: int) -> void:
	print("item at index %d was double clicked" % index)
