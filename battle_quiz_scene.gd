extends Control

@export var quiz_file: String
@onready var question_label = $QuestionLabel
@onready var timer_label = $TimerLabel
@onready var answer_buttons = $VBoxContainer
@onready var boss_hp_bar = $BossHp
@onready var player_hp_bar = $PlayerHp
@onready var anim_player = $AnimationPlayer

var questions = []
var current_question = {}
var question_index = 0
var boss_hp = 100
var player_hp = 100
var question_timer = 0.0
var timer_running = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_hp_bar.value = boss_hp
	player_hp_bar.value = player_hp
	_load_quiz()
	_next_question()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_running:
		question_timer += delta
		timer_label.text = "Timer: %.2f" % question_timer

func _load_quiz():
	var file = FileAccess.open(quiz_file, FileAccess.READ)
	print(file)
	if file:
		questions = JSON.parse_string(file.get_as_text())
		file.close()

func _next_question():
	if question_index >= questions.size():
		_end_battle("🎉 You completed the quiz")
		return
	question_timer = 0.0
	timer_running = true
	current_question = questions[question_index]
	question_label.text = current_question["question"]
	var options = ["a", "b", "c", "d"]
	for i in range(4):
		var btn = answer_buttons.get_child(i)
		btn.text = current_question[options[i]]
		for connection in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", connection.callable)
		btn.pressed.connect(_on_answer_pressed.bind(options[i]))
	question_index += 1

func _on_answer_pressed(choice):
	timer_running = false
	var time_bonus = clamp(5.0 - question_timer, 0.5, 5.0) # Faster answers = higher bonus
	
	if choice == current_question["correct"]:
		var damage = int(10 * time_bonus)
		boss_hp -= damage
		boss_hp = max(boss_hp, 0)
		boss_hp_bar.value = boss_hp
		#anim_player.play("boss_hit")
		#anim_player.play("shake")
	else:
		player_hp -= 10
		player_hp = max(player_hp, 0)
		player_hp_bar.value = player_hp
		#anim_player.play("player_hit")
		#anim_player.play("shake")
	
	# Delay next question for effect
	await get_tree().create_timer(0.8).timeout
	
	if boss_hp <= 0:
		_end_battle("🏆 You defeated the Boss!")
	elif player_hp <= 0:
		_end_battle("💀 You were defeated...")
	else:
		_next_question()


func _end_battle(message: String):
	question_label.text = message
	for i in range(answer_buttons.get_child_count()):
		answer_buttons.get_child(i).disabled = true
	timer_running = false
	await  get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://start_game_scene.tscn")
