extends Node

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
var board_state = []           # Representação do tabuleiro (placeholder)
var current_player = "branca"  # Jogador atual
var move_history = []          # Histórico de jogadas

const END_GAME_MENU = preload("res://cenas/end_game_menu.tscn")
const SAVE_PATH = "user://royal_legacy_save.json"

# ============================================================
# ===================== PERSISTÊNCIA ==========================
# ============================================================

func get_save_data() -> Dictionary:
	return {
		"state": current_state,
		"winner": winner,
		"board": board_state,
		"player": current_player,
		"history": move_history,
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
	board_state = save_data.get("board", [])
	current_player = save_data.get("player", "branca")
	move_history = save_data.get("history", [])

	print("Jogo carregado com sucesso.")
	return true


# ============================================================
# =============== IA — Movimentos Aleatórios ==================
# ============================================================

func get_all_valid_moves() -> Array:
	print("Obtendo movimentos válidos... (Placeholder)")

	# Apenas exemplos para teste da IA
	if current_player == "preta":
		return [
			{ "from": "a7", "to": "a6", "piece": "pawn" },
			{ "from": "b7", "to": "b6", "piece": "pawn" },
			{ "from": "g8", "to": "f6", "piece": "knight" },
		]
	else:
		return [
			{ "from": "e2", "to": "e4", "piece": "pawn" },
			{ "from": "d2", "to": "d4", "piece": "pawn" },
		]

func ai_make_move():
	if current_state != GameState.PLAYING:
		return
	if current_player != "preta":
		return

	var valid_moves = get_all_valid_moves()

	if valid_moves.size() > 0:
		randomize()
		var chosen_move = valid_moves[randi() % valid_moves.size()]

		execute_move(chosen_move)

		print("IA (Preta) moveu: %s de %s para %s"
			% [chosen_move.piece, chosen_move.from, chosen_move.to])

		current_player = "branca"


# ============================================================
# ===================== LÓGICA DO JOGO ========================
# ============================================================

func execute_move(move_data: Dictionary):
	# Placeholder da lógica real
	var notation = "%s%s%s" % [
		move_data.get("piece", "?"),
		move_data.get("from", "?"),
		move_data.get("to", "?"),
	]

	move_history.append(notation)
	print("Histórico atualizado: ", move_history)

func start_new_game():
	board_state = []
	current_player = "branca"
	move_history = []
	winner = ""
	current_state = GameState.PLAYING
	print("Novo jogo iniciado.")

func end_game(result: int):
	if current_state != GameState.PLAYING:
		return

	if result == 1:  # Xeque-mate
		winner = "branca" if current_player == "preta" else "preta"
		current_state = GameState.CHECKMATE
		print("Fim de jogo: Xeque-mate! Vencedor: " + winner)

	elif result == 2:  # Empate
		winner = "empate"
		current_state = GameState.STALEMATE
		print("Fim de jogo: Empate (Stalemate).")

	# Mostra menu final
	var end_game_menu = END_GAME_MENU.instantiate()
	get_tree().root.add_child(end_game_menu)


# ============================================================
# ============================ READY ==========================
# ============================================================

func _ready():
	if not DirAccess.dir_exists_absolute("user://"):
		DirAccess.make_dir_absolute("user://")

	start_new_game()

	if current_player == "branca":
		# Movimento do jogador (teste)
		execute_move({ "from": "e2", "to": "e4", "piece": "pawn" })
		current_player = "preta"

		# Movimento da IA
		ai_make_move()

		# Salvando
		save_game()

		# Alterando variáveis para testar carregamento
		current_state = GameState.MENU
		current_player = "none"
		move_history = []

		print("\n--- Teste de Carregamento ---")
		load_game()

		print("Estado após carregamento: ", current_state)
		print("Jogador atual após carregamento: ", current_player)
		print("Histórico após carregamento: ", move_history)
