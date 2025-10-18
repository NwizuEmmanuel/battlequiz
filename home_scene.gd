extends Control


@onready var confirm_exit = $ConfirmExit
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
	get_tree().change_scene_to_file("res://start_game_scene.tscn")
