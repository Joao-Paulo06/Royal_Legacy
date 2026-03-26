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
	
	# ESPERA 2 SEGUNDOS ANTES DE MUDAR DE TELA
	await get_tree().create_timer(2.0).timeout
	
	# Chama a troca de cena no formato seguro da Godot 4 (Callable)
	change_scene_game_over.call_deferred()
	
func set_winner(cor_vencedora: String):
	winner = cor_vencedora
	# Salva no Global (Autoload) para persistir entre cenas
	Global.vencedor = cor_vencedora 
	
	game_over.emit(winner)
	
	# ESPERA 2 SEGUNDOS ANTES DE MUDAR DE TELA
	await get_tree().create_timer(2.0).timeout
	
	change_scene_game_over.call_deferred()
	
# ==============================================================================
# TROCA DE CENAS
# ==============================================================================

func change_scene_game_over():
	var tree = get_tree()
	
	# Tentativa 1: O jeito normal
	if tree:
		tree.change_scene_to_file("res://cenas/end_game.tscn")
	# Tentativa 2 (Fallback): Se o GameManager estiver "flutuando", puxamos a árvore direto da Engine
	else:
		var main_loop = Engine.get_main_loop()
		if main_loop is SceneTree:
			main_loop.change_scene_to_file("res://cenas/end_game.tscn")
		else:
			print("ERRO CRÍTICO: Não foi possível acessar a SceneTree para trocar a cena.")

func start_new_game():
	winner = ""
	turn_count = 1
	
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://cenas/Tabuleiro.tscn")
	else:
		Engine.get_main_loop().change_scene_to_file("res://cenas/Tabuleiro.tscn")
