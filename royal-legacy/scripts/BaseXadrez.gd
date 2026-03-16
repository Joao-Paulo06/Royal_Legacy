extends Sprite2D

# ==============================================================================
# 1. CONFIGURAÇÕES E PRELOADS
# ==============================================================================

# Configurações Gerais
const TAMANHO_TABULEIRO := 8
const TAMANHO_CELULA := 60.0

# Texturas das Peças
const BISPO_BRANCO   = preload("uid://tsrh843l2ycr")
const BISPO_PRETO    = preload("uid://dvwybgmrfmhoe")
const CAVALO_BRANCO  = preload("uid://t1gw66fhf5sv")
const CAVALO_PRETO   = preload("uid://52hwqs8up4f7")
const PEAO_BRANCO    = preload("uid://61eaf3bd4usa")
const PEAO_PRETO     = preload("uid://bmmlr62nw3txa")
const RAINHA_BRANCA  = preload("uid://fuyoj0eebx58")
const RAINHA_PRETA   = preload("uid://d2ej8vtypvfhs")
const REI_BRANCO     = preload("uid://dbrigkc20j5jy")
const REI_PRETO      = preload("uid://cxsmjhjlpdlyk")
const TORRE_BRANCA   = preload("uid://uiwrboynrvyt")
const TORRE_PRETA    = preload("uid://s10ect4l8h2u")

# Interface e Efeitos
const CASAS             = preload("uid://c8snr6qequ51c")
const MOVIMENTACAO_PECA = preload("uid://dsbd2dsi7qewt")
const DESTAQUE_CAPTURA  = preload("uid://clml41oc6oqcq")
const TURNO_BRANCO      = preload("uid://b1pe1tl2cow1w")
const TURNO_PRETO       = preload("uid://djkjehjg6jdq2")

# Áudio
const SOM_CAPTURANDO = preload("uid://b7rtga1jwlm4s")
const SOM_MOVIMENTO  = preload("uid://dg3r16ow1l3vb")

# ==============================================================================
# 2. NÓS E VARIÁVEIS
# ==============================================================================

# Referências Visuais
@onready var pecas: Node2D = $pecas
@onready var quadrados: Node2D = $quadrados
@onready var turno: Sprite2D = $turno
@onready var check_indicator: ColorRect = $CheckIndicator
@onready var som_pecas: AudioStreamPlayer = $Som_pecas

# Estado do Jogo
var tabuleiro: Array = []
var brancas: bool = true          # Turno: true (Brancas), false (Pretas)
var situacao: bool = false        # Estado de seleção
var selecionar_peca: Vector2 = Vector2(-1, -1)
var movimento: Array = []         # Lista de movimentos válidos
var historico_partida: Array = [] # Pilha para guardar os estados anteriores
var modo_pve: bool = true   # Se true, joga contra o PC. Se false, PvP local.
var dificuldade_ia: int = 2 # 1 = Fácil, 2 = Médio, 3 = Difícil
var ia_pensando: bool = false

# Histórico e Regras Especiais
var ultimo_movimento = { "peca": 0, "origem": Vector2.ZERO, "destino": Vector2.ZERO }
var rei_moveu = { true: false, false: false } 
var torres_moveram = { 
	Vector2(0,0): false, Vector2(7,0): false, # Pretas
	Vector2(0,7): false, Vector2(7,7): false  # Brancas
}

# ==============================================================================
# 3. INICIALIZAÇÃO (_ready e _input)
# ==============================================================================

func _ready() -> void:
	modo_pve = Global.modo_pve
	dificuldade_ia = Global.dificuldade_escolhida

	var game_manager = get_game_manager()
	if game_manager:
		if not game_manager.check_state_changed.is_connected(_on_check_state_changed):
			game_manager.check_state_changed.connect(_on_check_state_changed)

	# Inicializa Matriz do Tabuleiro
	tabuleiro = [
		[-4, -2, -3, -5, -6, -3, -2, -4], # Pretas (Topo)
		[-1, -1, -1, -1, -1, -1, -1, -1],
		[ 0,  0,  0,  0,  0,  0,  0,  0],
		[ 0,  0,  0,  0,  0,  0,  0,  0],
		[ 0,  0,  0,  0,  0,  0,  0,  0],
		[ 0,  0,  0,  0,  0,  0,  0,  0],
		[ 1,  1,  1,  1,  1,  1,  1,  1],
		[ 4,  2,  3,  5,  6,  3,  2,  4]  # Brancas (Base)
	]
	exibir()

func _input(event) -> void:
	if ia_pensando or (modo_pve and not brancas):
		return
		
	if not (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		return

	var mouse_local = to_local(get_global_mouse_position())
	var origin = _get_board_origin()
	var cell = _get_cell_size()
	var mouse_board = mouse_local - origin

	if mouse_board.x < 0 or mouse_board.x >= TAMANHO_TABULEIRO * cell: return
	if mouse_board.y < 0 or mouse_board.y >= TAMANHO_TABULEIRO * cell: return

	var coluna := int(floor(mouse_board.x / cell))
	var linha := int(floor(mouse_board.y / cell))

	if not situacao and ((brancas and tabuleiro[linha][coluna] > 0) or (not brancas and tabuleiro[linha][coluna] < 0)):
		selecionar_peca = Vector2(coluna, linha)
		mostrar_opcoes()
		situacao = true
	elif situacao:
		definir_movimento(linha, coluna)
		
# ==============================================================================
# 4. LÓGICA DE MOVIMENTO (CORE)
# ==============================================================================

func definir_movimento(linha: int, coluna: int) -> void:
	var movimento_encontrado := false
	for i in movimento:
		if i.y == linha and i.x == coluna:
			movimento_encontrado = true
			break

	for child in quadrados.get_children():
		child.queue_free()
	situacao = false

	if movimento_encontrado:
		salvar_estado_atual()
		var distancia_x = coluna - selecionar_peca.x
		if abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]) == 6 and abs(distancia_x) == 2:
			var y = selecionar_peca.y
			if distancia_x == 2:   # Roque Curto
				tabuleiro[y][5] = tabuleiro[y][7]; tabuleiro[y][7] = 0
			elif distancia_x == -2: # Roque Longo
				tabuleiro[y][3] = tabuleiro[y][0]; tabuleiro[y][0] = 0

		var peca_destino_valor = tabuleiro[linha][coluna]
		var peca_movida_valor = tabuleiro[selecionar_peca.y][selecionar_peca.x]
		var pos_anterior = selecionar_peca
		
		tabuleiro[linha][coluna] = peca_movida_valor
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
		
		if peca_movida_valor == 1 and linha == 0:
			tabuleiro[linha][coluna] = 5  # Rainha Branca
		elif peca_movida_valor == -1 and linha == 7:
			tabuleiro[linha][coluna] = -5 # Rainha Preta

		if abs(peca_movida_valor) == 1 and peca_destino_valor == 0 and coluna != pos_anterior.x:
			var direcao_captura = 1 if brancas else -1
			var y_inimigo = linha + direcao_captura
			tabuleiro[y_inimigo][coluna] = 0
			peca_destino_valor = 999 

		if abs(peca_movida_valor) == 6:
			rei_moveu[brancas] = true
		if abs(peca_movida_valor) == 4 and pos_anterior in torres_moveram:
			torres_moveram[pos_anterior] = true

		if peca_destino_valor != 0: tocar_som(SOM_CAPTURANDO)
		else: tocar_som(SOM_MOVIMENTO)
			
		ultimo_movimento = {
			"peca": peca_movida_valor, "origem": pos_anterior, "destino": Vector2(coluna, linha)
		}

		brancas = not brancas
		exibir() 
		
		if esta_em_xeque(brancas):
			tocar_som(SOM_CAPTURANDO)
			animar_xeque_tela()
			destacar_rei_em_perigo(brancas)
			var gm = get_game_manager()
			if gm: gm.atualizar_xeque(true)
			
		if not brancas and modo_pve:
			iniciar_turno_ia()
			
		verificar_fim_de_jogo()

# ==============================================================================
# 5. CÁLCULO DE REGRAS (Movimentos Válidos)
# ==============================================================================

func mostrar_opcoes() -> void:
	movimento = pegar_movimento()
	if movimento.is_empty():
		situacao = false; return
	mostrar_quadrados()

func pegar_movimento() -> Array:
	match abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]):
		1: return peao_movimento()
		2: return cavalo_movimento()
		3: return bispo_movimento()
		4: return torre_movimento()
		5: return rainha_movimento()
		6: return rei_movimento()
	return []

func peao_movimento() -> Array:
	var _movs: Array = []
	var dir := 1 if not brancas else -1
	var pos := selecionar_peca + Vector2(0, dir)

	if posicao_valida(pos) and posicao_vazia(pos):
		_movs.append(pos)
		var prim_jogada := (brancas and selecionar_peca.y == 6) or (not brancas and selecionar_peca.y == 1)
		if prim_jogada:
			pos = selecionar_peca + Vector2(0, dir * 2)
			if posicao_valida(pos) and posicao_vazia(pos): _movs.append(pos)

	for i in [-1, 1]:
		pos = selecionar_peca + Vector2(i, dir)
		if posicao_valida(pos) and not posicao_vazia(pos) and pecas_inimigas(pos):
			_movs.append(pos)

	var linha_ep = 3 if brancas else 4
	if selecionar_peca.y == linha_ep:
		for i in [-1, 1]:
			var col_lado = selecionar_peca.x + i
			if col_lado >= 0 and col_lado < TAMANHO_TABULEIRO:
				var inimigo = -1 if brancas else 1
				var foi_peao = ultimo_movimento["peca"] == inimigo
				var dest_lado = ultimo_movimento["destino"] == Vector2(col_lado, selecionar_peca.y)
				var orig_topo = ultimo_movimento["origem"].y == (1 if brancas else 6)
				if foi_peao and dest_lado and orig_topo:
					_movs.append(Vector2(col_lado, selecionar_peca.y + dir))

	return filtrar_movimentos_ilegais(_movs)

func rei_movimento() -> Array:
	var _movs: Array = []
	var dirs = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	
	for d in dirs:
		var pos = selecionar_peca + d
		if posicao_valida(pos) and (posicao_vazia(pos) or pecas_inimigas(pos)):
			_movs.append(pos)
			
	if not rei_moveu[brancas] and not esta_em_xeque(brancas):
		var y = selecionar_peca.y
		var cor_ini = not brancas
		if tabuleiro[y][7] == (4 if brancas else -4) and not torres_moveram.get(Vector2(7, y), true):
			if tabuleiro[y][5] == 0 and tabuleiro[y][6] == 0 and not casa_sob_ataque(Vector2(5, y), cor_ini):
				_movs.append(Vector2(6, y))
		if tabuleiro[y][0] == (4 if brancas else -4) and not torres_moveram.get(Vector2(0, y), true):
			if tabuleiro[y][1] == 0 and tabuleiro[y][2] == 0 and tabuleiro[y][3] == 0 and not casa_sob_ataque(Vector2(3, y), cor_ini):
				_movs.append(Vector2(2, y))

	return filtrar_movimentos_ilegais(_movs)

func cavalo_movimento() -> Array:
	var _movs = []
	var dirs = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
	for d in dirs:
		var pos = selecionar_peca + d
		if posicao_valida(pos) and (posicao_vazia(pos) or pecas_inimigas(pos)): _movs.append(pos)
	return filtrar_movimentos_ilegais(_movs)

func torre_movimento() -> Array:
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]))

func bispo_movimento() -> Array:
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]))

func rainha_movimento() -> Array:
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]))

func movimento_linear(direcoes: Array) -> Array:
	var _movs: Array = []
	for d in direcoes:
		var pos = selecionar_peca + d
		while posicao_valida(pos):
			if posicao_vazia(pos): _movs.append(pos)
			else:
				if pecas_inimigas(pos): _movs.append(pos)
				break
			pos += d
	return _movs

# ==============================================================================
# 6. VALIDAÇÃO DE ESTADO (Xeque/Mate)
# ==============================================================================

func filtrar_movimentos_ilegais(movimentos: Array) -> Array:
	var legais: Array = []
	for m in movimentos:
		var origem = tabuleiro[selecionar_peca.y][selecionar_peca.x]
		var destino = tabuleiro[m.y][m.x]
		
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0; tabuleiro[m.y][m.x] = origem
		if not esta_em_xeque(brancas): legais.append(m)
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = origem; tabuleiro[m.y][m.x] = destino
	return legais

func esta_em_xeque(cor_rei: bool) -> bool:
	var pos_rei = encontrar_rei(cor_rei)
	if pos_rei == Vector2(-1, -1): return false
	return casa_sob_ataque(pos_rei, not cor_rei)

func encontrar_rei(cor_rei: bool) -> Vector2:
	var val = 6 if cor_rei else -6
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			if tabuleiro[y][x] == val: return Vector2(x, y)
	return Vector2(-1, -1)

func casa_sob_ataque(pos: Vector2, atacante: bool) -> bool:
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var val = tabuleiro[y][x]
			if val == 0: continue
			if (val > 0) == atacante:
				var movs = pegar_movimentos_brutos(Vector2(x, y))
				if pos in movs: return true
	return false

func pegar_movimentos_brutos(pos_peca: Vector2) -> Array:
	var sel_temp = selecionar_peca; var bra_temp = brancas
	selecionar_peca = pos_peca; brancas = tabuleiro[pos_peca.y][pos_peca.x] > 0
	
	var _movs = []
	match abs(tabuleiro[pos_peca.y][pos_peca.x]):
		1: _movs = peao_movimento_bruto()
		2: _movs = cavalo_movimento_bruto()
		3: _movs = movimento_linear_bruto([Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])
		4: _movs = movimento_linear_bruto([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)])
		5: _movs = movimento_linear_bruto([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])
		6: _movs = rei_movimento_bruto()
	
	selecionar_peca = sel_temp; brancas = bra_temp
	return _movs

func verificar_fim_de_jogo() -> void:
	var tem_mov = false
	var pecas_jogador: Array = []
	
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var val = tabuleiro[y][x]
			if val != 0 and (val > 0) == brancas: pecas_jogador.append(Vector2(x,y))

	var sel_temp = selecionar_peca
	for p in pecas_jogador:
		selecionar_peca = p
		if not pegar_movimento().is_empty():
			tem_mov = true; break
	selecionar_peca = sel_temp

	if not tem_mov:
		var gm = get_game_manager()
		if gm:
			if esta_em_xeque(brancas):
				var vencedor = "Pretas" if brancas else "Brancas"
				if gm.has_method("set_winner"): gm.set_winner(vencedor)
			else:
				if gm.has_method("set_winner"): gm.set_winner("Empate")

# ==============================================================================
# 7. FUNÇÕES AUXILIARES (BRUTOS)
# ==============================================================================

func movimento_linear_bruto(dirs: Array) -> Array:
	var _movs = []
	for d in dirs:
		var pos = selecionar_peca + d
		while posicao_valida(pos):
			_movs.append(pos)
			if not posicao_vazia(pos): break
			pos += d
	return _movs

func peao_movimento_bruto() -> Array:
	var _movs = []
	var dir = 1 if not brancas else -1
	for i in [-1, 1]:
		var pos = selecionar_peca + Vector2(i, dir)
		if posicao_valida(pos): _movs.append(pos)
	return _movs

func cavalo_movimento_bruto() -> Array:
	var _movs = []
	var dirs = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
	for d in dirs:
		var pos = selecionar_peca + d
		if posicao_valida(pos): _movs.append(pos)
	return _movs

func rei_movimento_bruto() -> Array:
	var _movs = []
	var dirs = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	for d in dirs:
		var pos = selecionar_peca + d
		if posicao_valida(pos): _movs.append(pos)
	return _movs

# ==============================================================================
# 8. SISTEMA VISUAL
# ==============================================================================

func exibir() -> void:
	for child in pecas.get_children(): child.queue_free()
	var origin = _get_board_origin()
	var cell = _get_cell_size()

	for i in range(TAMANHO_TABULEIRO):
		for j in range(TAMANHO_TABULEIRO):
			var casa = CASAS.instantiate()
			pecas.add_child(casa)
			casa.position = origin + Vector2(j * cell + cell * 0.5, i * cell + cell * 0.5)
			
			match tabuleiro[i][j]:
				-6: casa.texture = REI_PRETO;
				-5: casa.texture = RAINHA_PRETA; 
				-4: casa.texture = TORRE_PRETA;
				-3: casa.texture = BISPO_PRETO; 
				-2: casa.texture = CAVALO_PRETO; 
				-1: casa.texture = PEAO_PRETO;
				6: casa.texture = REI_BRANCO; 
				5: casa.texture = RAINHA_BRANCA; 
				4: casa.texture = TORRE_BRANCA
				3: casa.texture = BISPO_BRANCO; 
				2: casa.texture = CAVALO_BRANCO; 
				1: casa.texture = PEAO_BRANCO
			
			if brancas: turno.texture = TURNO_BRANCO
			else: turno.texture = TURNO_PRETO

func mostrar_quadrados() -> void:
	for child in quadrados.get_children(): child.queue_free()
	var origin = _get_board_origin()
	var cell = _get_cell_size()
	for i in movimento:
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = MOVIMENTACAO_PECA
		casa.position = origin + Vector2(i.x * cell + cell * 0.5, i.y * cell + cell * 0.5)
		if pecas_inimigas(i): casa.texture = DESTAQUE_CAPTURA

func animar_xeque_tela() -> void:
	if check_indicator:
		check_indicator.visible = true
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(check_indicator, "color", Color(1, 0, 0, 0.3), 0.2)
		tween.tween_property(check_indicator, "color", Color(1, 0, 0, 0.0), 0.2)

func destacar_rei_em_perigo(cor_branca: bool) -> void:
	var pos_rei = encontrar_rei(cor_branca)
	if pos_rei != Vector2(-1, -1):
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = DESTAQUE_CAPTURA
		var origin = _get_board_origin()
		var cell = _get_cell_size()
		casa.position = origin + Vector2(pos_rei.x * cell + cell * 0.5, pos_rei.y * cell + cell * 0.5)

func _on_check_state_changed(is_in_check: bool) -> void:
	if is_in_check: animar_xeque_tela()

# ==============================================================================
# 9. UTILITÁRIOS
# ==============================================================================

func get_game_manager() -> Node:
	var gm = get_node_or_null("GameManager")
	if not gm: gm = get_node_or_null("../GameManager")
	return gm

func tocar_som(som: AudioStream) -> void:
	if som_pecas:
		som_pecas.stream = som; som_pecas.play()

func _get_texture() -> Texture2D: return texture
func _get_texture_size() -> Vector2: return _get_texture().get_size() if _get_texture() else Vector2.ZERO
func _get_cell_size() -> float: return _get_texture_size().x / float(TAMANHO_TABULEIRO)
func _get_board_origin() -> Vector2: return -_get_texture_size() * 0.5 if centered else Vector2.ZERO

func mouse_off() -> bool:
	var m = to_local(get_global_mouse_position())
	var o = _get_board_origin(); var c = _get_cell_size()
	var s = Vector2(TAMANHO_TABULEIRO * c, TAMANHO_TABULEIRO * c)
	var r = m - o
	return r.x < 0 or r.y < 0 or r.x >= s.x or r.y >= s.y

func posicao_valida(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < TAMANHO_TABULEIRO and pos.y >= 0 and pos.y < TAMANHO_TABULEIRO

func posicao_vazia(pos: Vector2) -> bool: return tabuleiro[pos.y][pos.x] == 0
func pecas_inimigas(pos: Vector2) -> bool: return tabuleiro[pos.y][pos.x] != 0 and (tabuleiro[pos.y][pos.x] > 0) != brancas

# ==============================================================================
# 10. SISTEMA DE DESFAZER MOVIMENTO
# ==============================================================================

func salvar_estado_atual() -> void:
	var estado = {
		"tabuleiro": tabuleiro.duplicate(true),
		"brancas": brancas,
		"rei_moveu": rei_moveu.duplicate(),
		"torres_moveram": torres_moveram.duplicate(),
		"ultimo_movimento": ultimo_movimento.duplicate(),
		"situacao": situacao,
		"selecionar_peca": selecionar_peca
	}
	historico_partida.append(estado)

func desfazer_ultima_jogada() -> void:
	if historico_partida.is_empty(): return

	var estado_anterior = historico_partida.pop_back()
	tabuleiro = estado_anterior["tabuleiro"]
	brancas = estado_anterior["brancas"]
	rei_moveu = estado_anterior["rei_moveu"]
	torres_moveram = estado_anterior["torres_moveram"]
	ultimo_movimento = estado_anterior["ultimo_movimento"]

	situacao = false
	selecionar_peca = Vector2(-1, -1)
	movimento = []
	exibir()

	for child in quadrados.get_children(): child.queue_free()
	if check_indicator: check_indicator.color = Color(0,0,0,0)

func _on_btn_desfazer_mov_pressed() -> void:
	desfazer_ultima_jogada()
	
# ==============================================================================
# 11. INTELIGÊNCIA ARTIFICIAL (MINIMAX ALPHA-BETA)
# ==============================================================================

func iniciar_turno_ia() -> void:
	var gm = get_game_manager()
	if gm and gm.winner != "": return
	
	ia_pensando = true
	var tempo_espera = 0.5
	await get_tree().create_timer(tempo_espera).timeout
	
	var jogada = escolher_melhor_jogada()
	
	if jogada.is_empty():
		print("IA: Sem movimentos (Mate/Afogamento)")
		ia_pensando = false
		return

	executar_movimento_ia(jogada["origem"], jogada["destino"])
	ia_pensando = false

func executar_movimento_ia(origem: Vector2, destino: Vector2) -> void:
	selecionar_peca = origem
	movimento = [destino]
	definir_movimento(int(destino.y), int(destino.x))

# --- O CÉREBRO DA IA ---
func escolher_melhor_jogada() -> Dictionary:
	var melhor_jogada = {}
	var melhor_valor = 999999 # IA controla pretas, então quer o MENOR valor possível
	var profundidade = dificuldade_ia # Nível de dificuldade = Profundidade da busca

	var jogadas = obter_todos_movimentos_validos(false) # Pretas

	if jogadas.is_empty(): return {}

	# Loop Inicial para disparar o Minimax
	for jogada in jogadas:
		var peca_capturada = simular_mov_minimax(jogada)
		
		# Avalia o futuro a partir desse movimento (passa a vez para as Brancas = true)
		var valor_tabuleiro = minimax(profundidade - 1, -999999, 999999, true)
		
		desfazer_mov_minimax(jogada, peca_capturada)

		# Como somos as pretas, queremos MINIMIZAR a pontuação
		if valor_tabuleiro < melhor_valor:
			melhor_valor = valor_tabuleiro
			melhor_jogada = jogada

	# Prevenção: Se todas as jogadas forem muito ruins, garante que jogue a primeira
	if melhor_jogada.is_empty():
		melhor_jogada = jogadas[0]

	return melhor_jogada

# --- ALGORITMO MINIMAX RECURSIVO ---
func minimax(depth: int, alpha: int, beta: int, is_maximizing: bool) -> int:
	if depth == 0:
		return avaliar_estado_tabuleiro()

	var jogadas = obter_todos_movimentos_validos(is_maximizing)

	if jogadas.is_empty():
		if esta_em_xeque(is_maximizing):
			return -999999 if is_maximizing else 999999 # Xeque-mate (Brancas perdem = -, Pretas perdem = +)
		return 0 # Empate

	if is_maximizing: # Jogador (Brancas) quer maximizar
		var max_eval = -999999
		for jogada in jogadas:
			var capturada = simular_mov_minimax(jogada)
			var eval = minimax(depth - 1, alpha, beta, false)
			desfazer_mov_minimax(jogada, capturada)
			
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if beta <= alpha: break # Poda
		return max_eval
		
	else: # IA (Pretas) quer minimizar
		var min_eval = 999999
		for jogada in jogadas:
			var capturada = simular_mov_minimax(jogada)
			var eval = minimax(depth - 1, alpha, beta, true)
			desfazer_mov_minimax(jogada, capturada)
			
			min_eval = min(min_eval, eval)
			beta = min(beta, eval)
			if beta <= alpha: break # Poda
		return min_eval

# --- AVALIAÇÃO DO TABULEIRO (Score Global) ---
func avaliar_estado_tabuleiro() -> int:
	var score = 0
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var peca = tabuleiro[y][x]
			if peca == 0: continue

			var valor = obter_valor_peca(abs(peca))

			# Bônus de posição (Domínio do centro)
			if x >= 2 and x <= 5 and y >= 2 and y <= 5:
				valor += 5

			if peca > 0: # Brancas
				score += valor
			else:        # Pretas
				score -= valor
				
	return score

func obter_valor_peca(tipo_peca: int) -> int:
	match tipo_peca:
		1: return 10  # Peão
		2: return 30  # Cavalo
		3: return 30  # Bispo
		4: return 50  # Torre
		5: return 90  # Rainha
		6: return 900 # Rei
	return 0

# --- FUNÇÕES DE SIMULAÇÃO (rápidas, sem sons ou visuais) ---
func simular_mov_minimax(jogada: Dictionary) -> int:
	var origem = jogada["origem"]
	var destino = jogada["destino"]
	var peca_capturada = tabuleiro[destino.y][destino.x]
	
	tabuleiro[destino.y][destino.x] = tabuleiro[origem.y][origem.x]
	tabuleiro[origem.y][origem.x] = 0
	
	return peca_capturada

func desfazer_mov_minimax(jogada: Dictionary, peca_capturada: int) -> void:
	var origem = jogada["origem"]
	var destino = jogada["destino"]
	
	tabuleiro[origem.y][origem.x] = tabuleiro[destino.y][destino.x]
	tabuleiro[destino.y][destino.x] = peca_capturada

# Gera uma lista otimizada com todos os movimentos para a recursão
func obter_todos_movimentos_validos(para_brancas: bool) -> Array:
	var jogadas = []
	var backup_sel = selecionar_peca
	var backup_brancas = brancas

	brancas = para_brancas
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var val = tabuleiro[y][x]
			if val != 0 and (val > 0) == para_brancas:
				selecionar_peca = Vector2(x, y)
				var movs = pegar_movimento()
				for m in movs:
					jogadas.append({"origem": Vector2(x, y), "destino": m})

	selecionar_peca = backup_sel
	brancas = backup_brancas
	return jogadas
