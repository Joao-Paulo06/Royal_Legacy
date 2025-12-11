extends Node

# Sinais
signal check_state_changed(is_in_check)
signal game_over(vencedor)

# Variáveis
var winner: String = "" 
var turn_count: int = 1

# ==============================================================================
# FUNÇÕES DE ESTADO
# ==============================================================================

func atualizar_xeque(esta_em_xeque: bool):
	check_state_changed.emit(esta_em_xeque)

func end_game(tipo_resultado: int):
	# Tipo 1 = Xeque-mate | Tipo 2 = Empate
	if tipo_resultado == 2:
		winner = "empate"
	
	# Chama a troca de cena
	call_deferred("change_scene_game_over")

func set_winner(cor_vencedora: String):
	winner = cor_vencedora
	# Salva no Global (Autoload) para persistir entre cenas
	Global.vencedor = cor_vencedora 
	
	game_over.emit(winner)
	call_deferred("change_scene_game_over")

# ==============================================================================
# TROCA DE CENAS
# ==============================================================================

func change_scene_game_over():
	# Verifique o nome do arquivo na sua pasta (Maiúsculas/Minúsculas importam!)
	get_tree().change_scene_to_file("res://cenas/EndGame.tscn")

func start_new_game():
	winner = ""
	turn_count = 1
	get_tree().change_scene_to_file("res://cenas/Tabuleiro.tscn")
