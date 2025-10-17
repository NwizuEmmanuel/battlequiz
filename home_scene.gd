extends Control


@onready var file_dialog = $FileDialog
@onready var confirm_exit = $ConfirmExit
@onready var confirm_open_file = $ConfirmOpenFile
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_exit_to_desktop_pressed() -> void:
	confirm_exit.popup_centered()


func _on_confirm_exit_confirmed() -> void:
	get_tree().quit()


func _on_start_game_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
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
		confirm_open_file.dialog_text = "File imported successfully!"
		confirm_open_file.popup_centered()
	else:
		push_error("Failed to copy file! Error code: %s" % error)
		confirm_open_file.dialog_text("⚠️ Failed to import file.\nError code: %s" % error)
		confirm_open_file.popup_centered()
