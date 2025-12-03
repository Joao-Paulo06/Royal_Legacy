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
var winner = ""
var board_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
var current_player = "branca"
var move_history: Array = []
var ai_difficulty = 3

const END_GAME_MENU = preload("res://cenas/end_game_menu.tscn")
const SAVE_PATH = "user://royal_legacy_save.json"
const PYTHON_SCRIPT_PATH = "res://scripts/chess_bridge.py"

# ============================================================
# ===================== INTEGRAÇÃO PYTHON =====================
# ============================================================

func run_python_bridge(action: String, args: Array = []) -> Dictionary:
	var python_path = "python3"
	var script_path = ProjectSettings.globalize_path(PYTHON_SCRIPT_PATH)

	var exec_args: Array = []
	exec_args.append(script_path)
	exec_args.append(board_fen)
	exec_args.append(action)
	for a in args:
		exec_args.append(str(a))

	# output_lines será preenchido pelo OS.execute
	var output_lines: Array = []
	# chamada correta: comando, argumentos (Array), output (Array pass-by-ref), wait (bool)
	var exit_code: int = OS.execute(python_path, exec_args, output_lines, true)

	# Concatena manualmente as linhas de output em uma string
	var output_text: String = ""
	for line in output_lines:
		# garante que cada elemento seja string
		output_text += str(line) + "\n"
	output_text = output_text.strip_edges()

	# --- tratamento de erros ---
	if exit_code != 0:
		print("Erro ao executar Python (", action, ") exit_code=", exit_code)
		print("Saída:", output_text)
		return {
			"status": "error",
			"message": "Processo retornou erro.",
			"output": output_text
		}

	if output_text == "":
		print("Python retornou vazio.")
		return {
			"status": "error",
			"message": "stdout vazio."
		}

	var parsed = JSON.parse_string(output_text)
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed

	print("Falha ao parsear JSON:", output_text)
	return {
		"status": "error",
		"message": "JSON inválido.",
		"output": output_text
	}


# ============================================================
# ========================= IA (Stockfish) ====================
# ============================================================

func get_ai_move() -> String:
	var result = run_python_bridge("get_ai_move", [ai_difficulty])
	if result.get("status", "") == "success":
		return result.get("move_uci", "")
	print("Erro IA:", result.get("message", ""))
	return ""

func ai_make_move():
	if current_state != GameState.PLAYING or current_player != "preta":
		return

	var move_uci = get_ai_move()
	if move_uci != "":
		execute_move(move_uci)
		print("IA moveu:", move_uci)
	else:
		print("IA não conseguiu mover.")

# ============================================================
# ===================== LÓGICA DO JOGO ========================
# ============================================================

func is_move_valid(move_uci: String) -> bool:
	var result = run_python_bridge("validate_move", [move_uci])
	if result.get("status", "") == "success":
		return bool(result.get("is_legal", false))

	print("Erro validar movimento:", result.get("message", ""))
	return false

func execute_move(move_uci: String):
	if current_state != GameState.PLAYING:
		return

	var result = run_python_bridge("apply_move", [move_uci])
	if result.get("status", "") != "success":
		print("Erro ao aplicar movimento:", result.get("message", ""))
		return

	board_fen = result.get("new_fen", board_fen)
	move_history.append(move_uci)

	current_player = "preta" if current_player == "branca" else "branca"

	check_game_state()

	if current_state == GameState.PLAYING and current_player == "preta":
		ai_make_move()

func check_game_state():
	var result = run_python_bridge("get_game_state")

	if result.get("status", "") != "success":
		print("Erro ao verificar estado:", result.get("message", ""))
		return

	var state = result.get("state", "")
	var winner_color = result.get("winner", "")
	var is_check = bool(result.get("is_check", false))

	if state == "checkmate":
		end_game(1, winner_color)
	elif state == "stalemate" or state.begins_with("draw"):
		end_game(2)
	elif is_check:
		check_state_changed.emit(true)
	else:
		check_state_changed.emit(false)

func end_game(result_type: int, winner_color: String = ""):
	if current_state != GameState.PLAYING:
		return

	if result_type == 1:
		winner = winner_color
		current_state = GameState.CHECKMATE
		print("Xeque-mate! Vencedor:", winner)

	elif result_type == 2:
		winner = "empate"
		current_state = GameState.STALEMATE
		print("Empate!")

	var menu = END_GAME_MENU.instantiate()
	get_tree().root.add_child(menu)

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
