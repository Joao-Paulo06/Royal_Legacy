extends Control

@onready var winner_label = $VBoxContainer/WinnerLabel

func _ready():
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		var winner = str(game_manager.winner)

		if winner == "empate":
			winner_label.text = "Empate!"
		elif winner.is_empty():
			winner_label.text = "Jogo encerrado"
		else:
			winner_label.text = "Vencedor: " + winner.capitalize()
	else:
		winner_label.text = "Erro: GameManager não encontrado."


func _on_RestartButton_pressed():
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.start_new_game()

	get_tree().change_scene_to_file("res://cenas/novo_jogo_pve.tscn")
