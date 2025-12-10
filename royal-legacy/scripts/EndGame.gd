extends Control

@onready var winner_label: Label = $VBoxContainer/WinnerLabel

func _ready() -> void:
	# LÊ DO GLOBAL (Que nunca é destruído)
	var game_manager = get_node_or_null("../estruturador/tabuleiro/GameManager")
	
	# Prioridade: Lê do Global. Se estiver vazio, tenta achar o manager (caso de testes)
	var vencedor_final = Global.vencedor
	
	if vencedor_final == "":
		if game_manager:
			vencedor_final = game_manager.winner
	
	atualizar_mensagem_vitoria(vencedor_final)

func atualizar_mensagem_vitoria(valor_vencedor) -> void:
	var texto = str(valor_vencedor).to_lower()
	
	if texto == "empate" or texto == "2":
		winner_label.text = "Empate!"
	elif texto.is_empty():
		winner_label.text = "Jogo Encerrado"
	else:
		winner_label.text = "Vencedor: " + texto.capitalize()

func _on_restart_button_pressed() -> void:
	Global.vencedor = "" # Limpa o global
	get_tree().change_scene_to_file("res://cenas/estruturador.tscn") 
	# DICA: Volte para o 'estruturador.tscn' (menu principal/jogo) em vez de 'novo_jogo.tscn' 
	# se essa for sua cena principal.
