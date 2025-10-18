extends Control

@onready var open_quiz_file_dialog = $OpenQuizFileDialog
@onready var confirm_open_quiz = $ConfirmOpenQuiz
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("go_to_main_menu"):
		get_tree().change_scene_to_file("res://home_scene.tscn")


func _on_new_quiz_pressed() -> void:
	open_quiz_file_dialog.popup_centered()


func _on_open_quiz_file_dialog_file_selected(path: String) -> void:
	print("Selected file:", path)
	
	# Ensure the "quizzes" folder exists inside user://
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("quizzes"):
		var make_error = dir.make_dir("quizzes")
		if make_error == OK:
			print("Created folder: user://quizzes")
		else:
			push_error("Failed to create folder: user://quizzes")
			return
	
	# Build destination path
	var filename = path.get_file()
	var base_name = filename.get_basename()
	var extension = filename.get_extension()
	var destination_path = "user://quizzes/%s.%s" % [base_name, extension]
	
	# Auto-rename if file already exists
	var counter = 1
	while FileAccess.file_exists(destination_path):
		destination_path = "user://quizzes/%s_%d.%s" % [base_name, counter, extension]
		counter += 1
	
	# Copy the file safely
	var error = DirAccess.copy_absolute(path, destination_path)
	
	if error == OK:
		print("✅ File copied successfully to:", destination_path)
		confirm_open_quiz.dialog_text = "File imported successfully!"
		confirm_open_quiz.popup_centered()
	else:
		push_error("Failed to copy file! Error code: %s" % error)
		confirm_open_quiz.dialog_text("⚠️ Failed to import file.\nError code: %s" % error)
		confirm_open_quiz.popup_centered()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://home_scene.tscn")


func _on_select_quiz_pressed() -> void:
	get_tree().change_scene_to_file("res://select_quiz_scene.tscn")
