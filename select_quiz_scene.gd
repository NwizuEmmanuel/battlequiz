extends Control

@onready var quiz_list: ItemList = $ItemList

const QUIZ_FOLDER := "user://quizzes/"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure the folder exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(QUIZ_FOLDER):
		dir.make_dir(QUIZ_FOLDER)
	
	# Load quiz
	quiz_list.clear()
	dir = DirAccess.open(QUIZ_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				# Display name without extension
				var display_name = file_name.get_basename() # removes .json
				quiz_list.add_item(display_name)
				# Store the full name as metadata (for loading later)
				quiz_list.set_item_metadata(quiz_list.item_count -1, file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Failed to open quiz folder!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("go_to_main_menu"):
		get_tree().change_scene_to_file("res://home_scene.tscn")


func _on_item_list_item_selected(index: int) -> void:
	var full_file_name = quiz_list.get_item_metadata(index)
	print("Selected quiz file:", full_file_name)
