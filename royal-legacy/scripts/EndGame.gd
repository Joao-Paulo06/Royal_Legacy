extends Control

@onready var winner_label: Label = $VBoxContainer/WinnerLabel

# ==============================================================================
# 1. INICIALIZAÇÃO
# ==============================================================================

func _ready() -> void:
	# Tenta ler do Global, fallback para o GameManager se necessário
	var game_manager = get_node_or_null("../estruturador/tabuleiro/GameManager")
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

# ==============================================================================
# 2. SINAIS DOS BOTÕES
# ==============================================================================

func _on_restart_button_pressed() -> void:
	Global.vencedor = "" 
	# Garanta que o caminho abaixo aponta para sua cena principal
	get_tree().change_scene_to_file("res://cenas/estruturador.tscn")
