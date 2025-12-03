extends Node

signal check_state_changed(is_in_check)

enum GameState {
	MENU,
	SETUP,
	PLAYING,
	CHECKMATE,
	STALEMATE,
	DRAW
}

var current_state = GameState.MENU
var winner = ""                # "branca", "preta" ou "empate"
var board_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" # Estado do tabuleiro em FEN
var current_player = "branca"  # Jogador atual
var move_history = []          # Histórico de jogadas
var ai_difficulty = 3          # Nível de dificuldade da IA (1 a 5)

const END_GAME_MENU = preload("res://cenas/end_game_menu.tscn")
const SAVE_PATH = "user://royal_legacy_save.json"
const PYTHON_SCRIPT_PATH = "res://scripts/chess_bridge.py"

# ============================================================
# ===================== INTEGRAÇÃO PYTHON =====================
# ============================================================

func run_python_bridge(action: String, args: Array = []) -> Dictionary:
	var python_path = "python3"
	var script_path = ProjectSettings.globalize_path(PYTHON_SCRIPT_PATH)
	
	var command = python_path + " " + script_path + " " + board_fen + " " + action
	
	for arg in args:
		command += " " + str(arg)
		
	# Usar OS.execute para rodar o comando e capturar a saída
	# O Godot precisa ser configurado para permitir a execução de processos externos
	# (Project Settings -> General -> Debug -> External Editor -> Executable Path)
	# Assumindo que o ambiente sandbox permite a execução direta do python3
	var result = OS.execute("/bin/bash", ["-c", command], true, [])
	var exit_code = result[0]
	var output = result[1].strip()
	var error = result[2].strip()
	
	if exit_code != 0:
		print("Erro ao executar script Python (", action, "): ", error)
		return {"status": "error", "message": error}
		
	# Tentar parsear o JSON de saída
	var json_result = JSON.parse_string(output)
	if typeof(json_result) == TYPE_DICTIONARY:
		return json_result
	else:
		print("Erro ao parsear JSON do Python (", action, "): ", output)
		return {"status": "error", "message": "Saída inválida do script Python."}

# ============================================================
# ===================== PERSISTÊNCIA ==========================
# ============================================================

func get_save_data() -> Dictionary:
	return {
		"state": current_state,
		"winner": winner,
		"fen": board_fen, # Usando FEN
		"player": current_player,
		"history": move_history,
		"difficulty": ai_difficulty,
	}

func save_game() -> bool:
	var save_data = get_save_data()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("Jogo salvo com sucesso em: " + SAVE_PATH)
		return true
	else:
		print("Erro ao salvar o jogo.")
		return false

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nenhum arquivo de save encontrado.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("Erro ao abrir o arquivo de save.")
		return false

	var content = file.get_as_text()
	var save_data = JSON.parse_string(content)

	if typeof(save_data) != TYPE_DICTIONARY:
		print("Erro ao parsear dados salvos.")
		return false
	
	# Carrega os dados com segurança
	current_state = save_data.get("state", GameState.MENU)
	winner = save_data.get("winner", "")
	board_fen = save_data.get("fen", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	current_player = save_data.get("player", "branca")
	move_history = save_data.get("history", [])
	ai_difficulty = save_data.get("difficulty", 3)

	print("Jogo carregado com sucesso.")
	return true


# ============================================================
# ========================= IA (Stockfish) =====================
# ============================================================

func get_ai_move() -> String:
	var result = run_python_bridge("get_ai_move", [ai_difficulty])
	
	if result.status == "success":
		return result.move_uci
	else:
		print("Falha ao obter movimento da IA: ", result.message)
		return ""

func ai_make_move():
	if current_state != GameState.PLAYING:
		return
	if current_player != "preta": # Assumindo que a IA joga com as pretas
		return

	var move_uci = get_ai_move()
	
	if move_uci:
		# A IA retorna o movimento em UCI (ex: "e7e5")
		# A função execute_move precisa ser atualizada para receber o UCI e atualizar o FEN
		execute_move(move_uci)
		
		print("IA (Preta) moveu: ", move_uci)
		
		# A troca de jogador e a verificação de fim de jogo são feitas em execute_move
	else:
		# Se a IA não conseguir mover, pode ser um erro ou fim de jogo não detectado
		print("IA não conseguiu fazer um movimento.")


# ============================================================
# ===================== LÓGICA DO JOGO ========================
# ============================================================

# Função de validação de movimento para o jogador humano
func is_move_valid(move_uci: String) -> bool:
	var result = run_python_bridge("validate_move", [move_uci])
	
	if result.status == "success":
		return result.is_legal
	else:
		print("Falha na validação do movimento: ", result.message)
		return false

# Esta função deve ser chamada pela interface do usuário (UI)
# com o movimento em formato UCI (ex: "e2e4")
func execute_move(move_uci: String):
	if current_state != GameState.PLAYING:
		return
		
	# 1. Execução do movimento e atualização do FEN
	var result = run_python_bridge("apply_move", [move_uci])
	
	if result.status != "success":
		print("Movimento inválido ou erro ao aplicar: ", result.message)
		return
		
	board_fen = result.new_fen
	
	# 2. Registro do movimento
	move_history.append(move_uci)
	print("Histórico atualizado: ", move_history)
	print("Novo FEN: ", board_fen)
	
	# 3. Troca de jogador
	current_player = "preta" if current_player == "branca" else "branca"
	
	# 4. Verificação de fim de jogo
	check_game_state()
	
	# 5. Se for a vez da IA, ela move
	if current_state == GameState.PLAYING and current_player == "preta":
		ai_make_move()


func check_game_state():
	var result = run_python_bridge("get_game_state")
	
	if result.status != "success":
		print("Erro ao verificar estado do jogo: ", result.message)
		return
		
	var state = result.state
	var winner_color = result.winner
	var is_check = result.is_check
	
	if state == "checkmate":
		end_game(1, winner_color) # 1 para xeque-mate
	elif state == "stalemate" or state.begins_with("draw"):
		end_game(2) # 2 para empate
	elif is_check:
			print("O rei está em xeque!")
			check_state_changed.emit(true) # Notifica a UI sobre o xeque
	
		# Se o jogo continua, o estado é "playing" ou "check" (que é um sub-estado de playing)
		if not is_check:
			check_state_changed.emit(false) # Notifica a UI que o xeque foi removido (se estava)


func end_game(result_type: int, winner_color: String = ""):
	if current_state != GameState.PLAYING:
		return

	if result_type == 1:  # Xeque-mate
		winner = winner_color
		current_state = GameState.CHECKMATE
		print("Fim de jogo: Xeque-mate! Vencedor: " + winner)

	elif result_type == 2:  # Empate
		winner = "empate"
		current_state = GameState.STALEMATE
		print("Fim de jogo: Empate.")

	# Mostra menu final
	var end_game_menu = END_GAME_MENU.instantiate()
	get_tree().root.add_child(end_game_menu)


func start_new_game():
	board_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
	current_player = "branca"
	move_history = []
	winner = ""
	current_state = GameState.PLAYING
	print("Novo jogo iniciado.")


# ============================================================
# ============================ READY ==========================
# ============================================================

func _ready():
	if not DirAccess.dir_exists_absolute("user://"):
		DirAccess.make_dir_absolute("user://")

	start_new_game()

	# --- Teste de Fluxo ---
	# Simulação de um movimento humano (brancas)
	# O movimento deve ser em UCI (ex: "e2e4")
	# **IMPORTANTE:** A UI deve chamar execute_move(move_uci)
	
	# Simulação de um movimento válido (e2e4)
	if current_player == "branca":
		# Simulação de um movimento que leva a um estado de xeque (exemplo: e2e4, e7e5, d1h5)
		# Nota: O Stockfish pode não fazer o movimento e7e5 se não for o melhor.
		# Para testar o xeque-mate, precisaríamos de uma sequência específica.
		
		# Movimento 1: e2e4
		execute_move("e2e4")
		
		# Movimento 2 (IA): e7e5 (Se a IA fizer, senão o próximo movimento será diferente)
		# Se a IA mover, o current_player será "branca" novamente.
		
		# Movimento 3: d1h5 (Ataque da Rainha)
		if current_state == GameState.PLAYING and current_player == "branca":
			# Se a IA moveu, o FEN mudou. Vamos simular um movimento humano.
			# Para um teste mais robusto, a UI deve garantir que o movimento é legal.
			# Aqui, vamos simular um movimento que a UI faria.
			# Exemplo de movimento: d2d4
			execute_move("d2d4")
			
		save_game()
		
	# Simulação de carregamento (apenas para teste)
	# current_state = GameState.MENU
	# current_player = "none"
	# move_history = []
	# print("\n--- Teste de Carregamento ---")
	# load_game()
	# print("Estado após carregamento: ", current_state)
	# print("Jogador atual após carregamento: ", current_player)
	# print("Histórico após carregamento: ", move_history)
	# -----------------------------
