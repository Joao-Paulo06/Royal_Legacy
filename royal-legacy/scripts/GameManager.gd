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
var board_state = [] 
var current_player = "white" 
var move_history = [] 


# Funções de Persistência (Salvar/Carregar)


const SAVE_PATH = "user://royal_legacy_save.json"

func get_save_data():
	
	return {
		"state": current_state,
		"board": board_state,
		"player": current_player,
		"history": move_history,
		
	}

func save_game():
	var save_data = get_save_data()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("Jogo salvo com sucesso em: " + SAVE_PATH)
		return true
	else:
		print("Erro ao salvar o jogo.")
		return false

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nenhum arquivo de save encontrado.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var save_data = JSON.parse_string(content)
		
		if save_data:
			current_state = save_data.state
			board_state = save_data.board
			current_player = save_data.player
			move_history = save_data.history
			print("Jogo carregado com sucesso.")
			
			return true
		else:
			print("Erro ao parsear dados salvos.")
			return false
	else:
		print("Erro ao carregar o jogo.")
		return false


# Funções da IA (Modo Simples e Movimentos Aleatórios Válidos)

func get_all_valid_moves():
	
	print("Obtendo movimentos válidos... (Placeholder)")
	
	# Simulação de movimentos válidos (apenas para teste da IA)
	if current_player == "black":
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
	if current_state != GameState.PLAYING or current_player != "black":
		return
		
	var valid_moves = get_all_valid_moves()
	
	if valid_moves.size() > 0:
		# Escolhe um movimento aleatório (Modo Simples)
		randomize()
		var chosen_move = valid_moves[randi() % valid_moves.size()]
		
		# Simula a execução do movimento 
		execute_move(chosen_move)
		print("IA (Black) moveu: " + chosen_move.piece + " de " + chosen_move.from + " para " + chosen_move.to)
		current_player = "white"
		
# Funções de Lógica do Jogo (Placeholder para integração futura)
func execute_move(move_data):
	# Placeholder para a lógica de movimento real 
	# Atualiza o estado do tabuleiro 
	# Atualiza o Histórico de Jogadas 
	var notation = move_data.piece + move_data.from + move_data.to # Notação simplificada
	move_history.append(notation)
	print("Histórico atualizado: " + str(move_history))
	pass

func start_new_game():
	# Inicializa o tabuleiro e o estado do jogo
	board_state = [] # Reinicializa o tabuleiro
	current_player = "white"
	move_history = []
	current_state = GameState.PLAYING
	print("Novo jogo iniciado.")



func _ready():
	
	if not DirAccess.dir_exists_absolute("user://"):
		DirAccess.make_dir_absolute("user://")
		
	
	start_new_game()
	
	
	if current_player == "white":
		# Simula o movimento do jogador (Branca)
		execute_move({ "from": "e2", "to": "e4", "piece": "pawn" })
		current_player = "black"
		
		# Chama o movimento da IA
		ai_make_move()
		
		# Teste de Salvar/Carregar
		save_game()
		
		# Simula o carregamento para verificar se o histórico e o estado persistem
		current_state = GameState.MENU # Altera o estado para simular que o jogo foi fechado
		current_player = "none"
		move_history = []
		
		print("\n--- Teste de Carregamento ---")
		load_game()
		print("Estado após carregamento: " + str(current_state))
		print("Jogador atual após carregamento: " + current_player)
		print("Histórico após carregamento: " + str(move_history))
		
	pass
