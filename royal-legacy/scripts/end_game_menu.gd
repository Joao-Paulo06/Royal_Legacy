extends Control

@onready var winner_label = $VBoxContainer/WinnerLabel

func _ready():
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		var winner = game_manager.winner
		if winner == "empate":
			winner_label.text = "Empate!"
		else:
			winner_label.text = "Vencedor: " + winner.capitalize()

func _on_RestartButton_pressed():
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.start_new_game()
	get_tree().change_scene_to_file("res://cenas/novo_jogo_pve.tscn")
