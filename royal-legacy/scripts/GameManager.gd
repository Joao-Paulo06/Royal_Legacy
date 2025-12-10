extends Node

# Sinais para avisar o resto do jogo
signal check_state_changed(is_in_check)
signal game_over(vencedor)

# Variáveis simples
var winner: String = "" # "" = jogando, "brancas", "pretas", "empate"
var turn_count: int = 1

# ============================================================
# LÓGICA DE FIM DE JOGO
# ============================================================

func end_game(tipo_resultado: int):
	# Tipo 1 = Xeque-mate
	# Tipo 2 = Empate/Afogamento
	
	if tipo_resultado == 1:
		# Se as brancas estavam jogando e levaram mate, as pretas ganharam (e vice-versa)
		# Mas o tabuleiro geralmente chama end_game DEPOIS de trocar o turno.
		# Vamos simplificar: O tabuleiro vai passar quem GANHOU ou vamos deduzir.
		
		# Se eu chamo end_game(1), significa que o jogador ATUAL perdeu.
		# Vamos definir isso na hora que chamar.
		pass 
		
	elif tipo_resultado == 2:
		winner = "empate"

	print("Fim de jogo! Resultado:", winner)
	
	# Carrega a cena de Fim de Jogo (Game Over)
	# Certifique-se que o caminho do arquivo está correto!
	call_deferred("change_scene_game_over")

func set_winner(cor_vencedora: String):
	winner = cor_vencedora
	# SALVA NO GLOBAL ANTES DE MUDAR DE CENA
	Global.vencedor = cor_vencedora 
	
	game_over.emit(winner)
	call_deferred("change_scene_game_over")

func change_scene_game_over():
	# Ajuste o caminho para onde está sua tela de game over
	get_tree().change_scene_to_file("res://cenas/end_game_menu.tscn")

# ============================================================
# REINICIAR
# ============================================================

func start_new_game():
	winner = ""
	turn_count = 1
	# Recarrega a cena do tabuleiro
	get_tree().change_scene_to_file("res://cenas/tabuleiro.tscn")
