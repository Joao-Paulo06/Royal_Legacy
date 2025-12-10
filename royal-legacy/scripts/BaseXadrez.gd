extends Sprite2D

# ==============================================================================
# 1. CONFIGURAÇÕES E ASSETS
# ==============================================================================

# Configurações do Tabuleiro
const TAMANHO_TABULEIRO := 8
const TAMANHO_CELULA := 60.0

# Preload das Peças (Texturas)
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

# Preload de Interface e Efeitos
const CASAS             = preload("uid://c8snr6qequ51c")
const MOVIMENTACAO_PECA = preload("uid://dsbd2dsi7qewt")
const DESTAQUE_CAPTURA  = preload("uid://clml41oc6oqcq")
const TURNO_BRANCO      = preload("uid://b1pe1tl2cow1w")
const TURNO_PRETO       = preload("uid://djkjehjg6jdq2")

# Preload de Áudio
const SOM_CAPTURANDO = preload("uid://b7rtga1jwlm4s")
const SOM_MOVIMENTO  = preload("uid://dg3r16ow1l3vb")

# ==============================================================================
# 2. NÓS E VARIÁVEIS DO JOGO
# ==============================================================================

# Nós da Cena (OnReady)
@onready var pecas: Node2D = $pecas
@onready var quadrados: Node2D = $quadrados
@onready var turno: Sprite2D = $turno
@onready var check_indicator: ColorRect = $CheckIndicator
@onready var som_pecas: AudioStreamPlayer = $Som_pecas

# Variáveis de Estado
var tabuleiro: Array = []
var brancas: bool = true          # Turno: true (Brancas), false (Pretas)
var situacao: bool = false        # Estado: true se uma peça está selecionada
var selecionar_peca: Vector2 = Vector2(-1, -1)
var movimento: Array = []         # Lista de movimentos possíveis da peça atual

# Histórico e Regras Especiais
var ultimo_movimento = { "peca": 0, "origem": Vector2.ZERO, "destino": Vector2.ZERO }
var rei_moveu = { true: false, false: false } # Rastreia se o Rei já moveu (para Roque)
var torres_moveram = { 
	Vector2(0,0): false, Vector2(7,0): false, # Torres Pretas
	Vector2(0,7): false, Vector2(7,7): false  # Torres Brancas
}

# ==============================================================================
# 3. INICIALIZAÇÃO E INPUT
# ==============================================================================

func _ready() -> void:
	# Conecta ao GameManager para gerenciar som de Xeque/Vitória
	var game_manager = get_node("../tabuleiro/GameManager")
	if game_manager:
		game_manager.check_state_changed.connect(_on_check_state_changed)

	# Inicializa matriz do tabuleiro (Positivos = Brancas, Negativos = Pretas)
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
	if not (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		return

	# Converte clique do mouse para coordenadas da grade (ex: 0,0 a 7,7)
	var mouse_local = to_local(get_global_mouse_position())
	var origin = _get_board_origin()
	var cell = _get_cell_size()
	var mouse_board = mouse_local - origin

	# Validação: Clique dentro do tabuleiro?
	if mouse_board.x < 0 or mouse_board.x >= TAMANHO_TABULEIRO * cell: return
	if mouse_board.y < 0 or mouse_board.y >= TAMANHO_TABULEIRO * cell: return

	var coluna := int(floor(mouse_board.x / cell))
	var linha := int(floor(mouse_board.y / cell))

	# Lógica de Seleção:
	# Se nada selecionado e clicou em peça aliada -> Seleciona
	if not situacao and ((brancas and tabuleiro[linha][coluna] > 0) or (not brancas and tabuleiro[linha][coluna] < 0)):
		selecionar_peca = Vector2(coluna, linha)
		mostrar_opcoes()
		situacao = true
	# Se já selecionado -> Tenta mover
	elif situacao:
		definir_movimento(linha, coluna)

# ==============================================================================
# 4. LÓGICA PRINCIPAL DE MOVIMENTO (CORE)
# ==============================================================================

func definir_movimento(linha: int, coluna: int) -> void:
	# Verifica se o clique foi em uma casa válida (está na lista 'movimento'?)
	var movimento_encontrado := false
	for i in movimento:
		if i.y == linha and i.x == coluna:
			movimento_encontrado = true
			break

	# Limpa interface visual
	for child in quadrados.get_children():
		child.queue_free()
	situacao = false

	if movimento_encontrado:
		# --- A. LÓGICA DO ROQUE (Mover Torre) ---
		var distancia_x = coluna - selecionar_peca.x
		# Se é Rei (6) e moveu 2 casas, é Roque
		if abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]) == 6 and abs(distancia_x) == 2:
			var y = selecionar_peca.y
			if distancia_x == 2: # Roque Curto (Direita)
				tabuleiro[y][5] = tabuleiro[y][7]
				tabuleiro[y][7] = 0
			elif distancia_x == -2: # Roque Longo (Esquerda)
				tabuleiro[y][3] = tabuleiro[y][0]
				tabuleiro[y][0] = 0

		# --- B. PREPARAÇÃO DO MOVIMENTO ---
		var peca_destino_valor = tabuleiro[linha][coluna]
		var peca_movida_valor = tabuleiro[selecionar_peca.y][selecionar_peca.x]
		var pos_anterior = selecionar_peca
		
		# --- C. EXECUTA MOVIMENTO ---
		tabuleiro[linha][coluna] = peca_movida_valor
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
		
		# --- D. PROMOÇÃO DE PEÃO ---
		# Se Peão chegou na última linha, vira Rainha
		if peca_movida_valor == 1 and linha == 0:
			tabuleiro[linha][coluna] = 5  # Rainha Branca
		elif peca_movida_valor == -1 and linha == 7:
			tabuleiro[linha][coluna] = -5 # Rainha Preta

		# --- E. EN PASSANT ---
		# Se Peão moveu na diagonal para casa vazia, captura o peão atrás
		if abs(peca_movida_valor) == 1 and peca_destino_valor == 0 and coluna != pos_anterior.x:
			var direcao_captura = 1 if brancas else -1
			var y_inimigo = linha + direcao_captura
			tabuleiro[y_inimigo][coluna] = 0 # Remove inimigo
			peca_destino_valor = 999         # Força som de captura

		# --- F. ATUALIZA FLAGS (Para impedir Roque futuro) ---
		if abs(peca_movida_valor) == 6:
			rei_moveu[brancas] = true
		if abs(peca_movida_valor) == 4:
			if pos_anterior in torres_moveram:
				torres_moveram[pos_anterior] = true

		# --- G. FINALIZAÇÃO (Som, Histórico, Turno) ---
		if peca_destino_valor != 0:
			tocar_som(SOM_CAPTURANDO)
		else:
			tocar_som(SOM_MOVIMENTO)
			
		ultimo_movimento = {
			"peca": peca_movida_valor,
			"origem": pos_anterior,
			"destino": Vector2(coluna, linha)
		}

		brancas = not brancas
		verificar_fim_de_jogo()
		exibir()

# ==============================================================================
# 5. CÁLCULO DE MOVIMENTOS (REGRAS)
# ==============================================================================

func mostrar_opcoes() -> void:
	movimento = pegar_movimento()
	if movimento.is_empty():
		situacao = false
		return
	mostrar_quadrados()

func pegar_movimento() -> Array:
	var _movimento: Array = []
	match abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]):
		1: _movimento = peao_movimento()
		2: _movimento = cavalo_movimento()
		3: _movimento = bispo_movimento()
		4: _movimento = torre_movimento()
		5: _movimento = rainha_movimento()
		6: _movimento = rei_movimento()
	return _movimento

# --- Movimentos Específicos das Peças ---

func peao_movimento() -> Array:
	var _movimento: Array = []
	var direcao := 1 if not brancas else -1 # Pretas descem (+1), Brancas sobem (-1)
	var pos := selecionar_peca + Vector2(0, direcao)

	# 1. Movimento Simples
	if posicao_valida(pos) and posicao_vazia(pos):
		_movimento.append(pos)
		# 2. Movimento Duplo Inicial
		var primeira_jogada := (brancas and selecionar_peca.y == 6) or (not brancas and selecionar_peca.y == 1)
		if primeira_jogada:
			pos = selecionar_peca + Vector2(0, direcao * 2)
			if posicao_valida(pos) and posicao_vazia(pos):
				_movimento.append(pos)

	# 3. Captura Diagonal Normal
	for i in [-1, 1]:
		pos = selecionar_peca + Vector2(i, direcao)
		if posicao_valida(pos) and not posicao_vazia(pos) and pecas_inimigas(pos):
			_movimento.append(pos)

	# 4. En Passant
	var linha_en_passant = 3 if brancas else 4
	if selecionar_peca.y == linha_en_passant:
		for i in [-1, 1]:
			var coluna_lado = selecionar_peca.x + i
			if coluna_lado >= 0 and coluna_lado < TAMANHO_TABULEIRO:
				var peao_inimigo_valor = -1 if brancas else 1
				# Checa se o último movimento foi um avanço duplo de peão ao lado
				var foi_peao = ultimo_movimento["peca"] == peao_inimigo_valor
				var destino_lado = ultimo_movimento["destino"] == Vector2(coluna_lado, selecionar_peca.y)
				var origem_topo = ultimo_movimento["origem"].y == (1 if brancas else 6)
				
				if foi_peao and destino_lado and origem_topo:
					_movimento.append(Vector2(coluna_lado, selecionar_peca.y + direcao))

	return filtrar_movimentos_ilegais(_movimento)

func rei_movimento() -> Array:
	var _movimento: Array = []
	var direcoes = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),
					Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	
	# 1. Movimento Normal
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos) and (posicao_vazia(pos) or pecas_inimigas(pos)):
			_movimento.append(pos)
			
	# 2. Roque
	if not rei_moveu[brancas] and not esta_em_xeque(brancas):
		var y = selecionar_peca.y
		var cor_inimiga = not brancas
		
		# Roque Curto
		var torre_dir = Vector2(7, y)
		if tabuleiro[y][7] == (4 if brancas else -4) and not torres_moveram.get(torre_dir, true):
			if tabuleiro[y][5] == 0 and tabuleiro[y][6] == 0:
				if not casa_sob_ataque(Vector2(5, y), cor_inimiga):
					_movimento.append(Vector2(6, y))

		# Roque Longo
		var torre_esq = Vector2(0, y)
		if tabuleiro[y][0] == (4 if brancas else -4) and not torres_moveram.get(torre_esq, true):
			if tabuleiro[y][1] == 0 and tabuleiro[y][2] == 0 and tabuleiro[y][3] == 0:
				if not casa_sob_ataque(Vector2(3, y), cor_inimiga):
					_movimento.append(Vector2(2, y))

	return filtrar_movimentos_ilegais(_movimento)

# Outros movimentos (Genéricos)
func cavalo_movimento() -> Array:
	var direcoes = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),
					Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
	var _movimento = []
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos) and (posicao_vazia(pos) or pecas_inimigas(pos)):
			_movimento.append(pos)
	return filtrar_movimentos_ilegais(_movimento)

func torre_movimento() -> Array:
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]))

func bispo_movimento() -> Array:
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]))

func rainha_movimento() -> Array:
	return filtrar_movimentos_ilegais(movimento_linear([
		Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),
		Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]))

func movimento_linear(direcoes: Array) -> Array:
	var _movimento: Array = []
	for d in direcoes:
		var pos = selecionar_peca + d
		while posicao_valida(pos):
			if posicao_vazia(pos):
				_movimento.append(pos)
			else:
				if pecas_inimigas(pos):
					_movimento.append(pos)
				break
			pos += d
	return _movimento

# ==============================================================================
# 6. VALIDAÇÃO DE XEQUE E FIM DE JOGO
# ==============================================================================

func filtrar_movimentos_ilegais(movimentos: Array) -> Array:
	var movimentos_legais: Array = []
	for m in movimentos:
		var peca_origem = tabuleiro[selecionar_peca.y][selecionar_peca.x]
		var peca_destino = tabuleiro[m.y][m.x]
		
		# Simula movimento
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
		tabuleiro[m.y][m.x] = peca_origem

		if not esta_em_xeque(brancas):
			movimentos_legais.append(m)

		# Desfaz simulação
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = peca_origem
		tabuleiro[m.y][m.x] = peca_destino
	return movimentos_legais

func esta_em_xeque(cor_rei: bool) -> bool:
	var pos_rei = encontrar_rei(cor_rei)
	if pos_rei == Vector2.ONE * -1: return false
	return casa_sob_ataque(pos_rei, not cor_rei)

func encontrar_rei(cor_rei: bool) -> Vector2:
	var valor_rei = 6 if cor_rei else -6
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			if tabuleiro[y][x] == valor_rei:
				return Vector2(x, y)
	return Vector2.ONE * -1

func casa_sob_ataque(pos: Vector2, cor_atacante: bool) -> bool:
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var peca_valor = tabuleiro[y][x]
			if peca_valor == 0: continue
			var peca_cor_branca = peca_valor > 0
			if peca_cor_branca == cor_atacante:
				# Gera movimentos brutos (sem filtrar xeque) para ver se atinge 'pos'
				var movimentos_brutos = pegar_movimentos_brutos(Vector2(x, y))
				for m in movimentos_brutos:
					if m == pos: return true
	return false

func pegar_movimentos_brutos(pos_peca: Vector2) -> Array:
	var temp_selecionar_peca = selecionar_peca
	var temp_brancas = brancas

	selecionar_peca = pos_peca
	brancas = tabuleiro[pos_peca.y][pos_peca.x] > 0

	var _movimento: Array = []
	match abs(tabuleiro[pos_peca.y][pos_peca.x]):
		1: _movimento = peao_movimento_bruto()
		2: _movimento = cavalo_movimento_bruto()
		3: _movimento = movimento_linear_bruto([Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])
		4: _movimento = movimento_linear_bruto([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)])
		5: _movimento = movimento_linear_bruto([
			Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),
			Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])
		6: _movimento = rei_movimento_bruto()

	selecionar_peca = temp_selecionar_peca
	brancas = temp_brancas
	return _movimento

func verificar_fim_de_jogo() -> void:
	var tem_movimento_legal = false
	var pecas_jogador_atual: Array = []
	
	# 1. Encontra todas as peças do jogador atual
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var peca_valor = tabuleiro[y][x]
			if peca_valor != 0 and (peca_valor > 0) == brancas:
				pecas_jogador_atual.append(Vector2(x,y))

	# 2. CALCULA se existe algum movimento válido
	var temp_selecionar_peca = selecionar_peca
	for p in pecas_jogador_atual:
		selecionar_peca = p
		if not pegar_movimento().is_empty():
			tem_movimento_legal = true
			break
	selecionar_peca = temp_selecionar_peca

	# 3. SÓ AGORA verifica se acabou o jogo
	if not tem_movimento_legal:
		# Ajuste o caminho conforme sua árvore de cena real
		# Se o GameManager for filho direto do tabuleiro: get_node("GameManager")
		# Se for irmão: get_node("../GameManager")
		var game_manager = get_node_or_null("../estruturador/tabuleiro/GameManager")
		
		# Fallback: Tenta achar GameManager como filho se o caminho longo falhar
		if not game_manager:
			game_manager = get_node_or_null("GameManager")

		if game_manager:
			if esta_em_xeque(brancas):
				var quem_ganhou = "Pretas" if brancas else "Brancas"
				if game_manager.has_method("set_winner"):
					game_manager.set_winner(quem_ganhou)
			else:
				if game_manager.has_method("set_winner"):
					game_manager.set_winner("Empate")
		else:
			print("ERRO CRÍTICO: GameManager não encontrado!")

# ==============================================================================
# 7. AUXILIARES BRUTOS (Para cálculo de ataque)
# ==============================================================================

func movimento_linear_bruto(direcoes: Array) -> Array:
	var _movimento: Array = []
	for d in direcoes:
		var pos = selecionar_peca + d
		while posicao_valida(pos):
			_movimento.append(pos)
			if not posicao_vazia(pos): break
			pos += d
	return _movimento

func peao_movimento_bruto() -> Array:
	var _movimento: Array = []
	var direcao := 1 if not brancas else -1
	for i in [-1, 1]:
		var pos = selecionar_peca + Vector2(i, direcao)
		if posicao_valida(pos): _movimento.append(pos)
	return _movimento

func cavalo_movimento_bruto() -> Array:
	var _movimento: Array = []
	var direcoes = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),
					Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos): _movimento.append(pos)
	return _movimento

func rei_movimento_bruto() -> Array:
	var _movimento: Array = []
	var direcoes = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),
					Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos): _movimento.append(pos)
	return _movimento

# ==============================================================================
# 8. SISTEMA VISUAL
# ==============================================================================

func exibir() -> void:
	for child in pecas.get_children():
		child.queue_free()

	var origin = _get_board_origin()
	var cell = _get_cell_size()

	for i in range(TAMANHO_TABULEIRO):
		for j in range(TAMANHO_TABULEIRO):
			var casa = CASAS.instantiate()
			pecas.add_child(casa)
			casa.position = origin + Vector2(j * cell + cell * 0.5, i * cell + cell * 0.5)
			
			match tabuleiro[i][j]:
				-6: casa.texture = REI_PRETO
				-5: casa.texture = RAINHA_PRETA
				-4: casa.texture = TORRE_PRETA
				-3: casa.texture = BISPO_PRETO
				-2: casa.texture = CAVALO_PRETO
				-1: casa.texture = PEAO_PRETO
				6: casa.texture = REI_BRANCO
				5: casa.texture = RAINHA_BRANCA
				4: casa.texture = TORRE_BRANCA
				3: casa.texture = BISPO_BRANCO
				2: casa.texture = CAVALO_BRANCO
				1: casa.texture = PEAO_BRANCO
			
			if brancas: turno.texture = TURNO_BRANCO
			else: turno.texture = TURNO_PRETO

func mostrar_quadrados() -> void:
	for child in quadrados.get_children():
		child.queue_free()

	var origin = _get_board_origin()
	var cell = _get_cell_size()
	for i in movimento:
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = MOVIMENTACAO_PECA
		casa.position = origin + Vector2(i.x * cell + cell * 0.5, i.y * cell + cell * 0.5)
		
		# Destaque vermelho para capturas
		if pecas_inimigas(i):
			casa.texture = DESTAQUE_CAPTURA

func _on_check_state_changed(is_in_check: bool) -> void:
	if is_in_check:
		var tween = check_indicator.create_tween()
		tween.set_loops()
		tween.tween_property(check_indicator, "color", Color(1, 0, 0, 0.2), 0.5)
		tween.tween_property(check_indicator, "color", Color(1, 0, 0, 0.0), 0.5)
	else:
		check_indicator.get_tree().create_tween().kill()
		check_indicator.color = Color(1, 0, 0, 0)

# ==============================================================================
# 9. UTILITÁRIOS
# ==============================================================================

func tocar_som(som: AudioStream) -> void:
	if som_pecas:
		som_pecas.stream = som
		som_pecas.play()

func _get_texture() -> Texture2D:
	return texture

func _get_texture_size() -> Vector2:
	var tex = _get_texture()
	if tex == null: return Vector2.ZERO
	return tex.get_size()

func _get_cell_size() -> float:
	var tex_size = _get_texture_size()
	if tex_size.x == 0: return TAMANHO_CELULA
	return tex_size.x / float(TAMANHO_TABULEIRO)

func _get_board_origin() -> Vector2:
	var tex_size = _get_texture_size()
	if centered: return -tex_size * 0.5
	else: return Vector2.ZERO

func mouse_off() -> bool:
	var mouse_local = to_local(get_global_mouse_position())
	var origin = _get_board_origin()
	var cell = _get_cell_size()
	var board_size = Vector2(TAMANHO_TABULEIRO * cell, TAMANHO_TABULEIRO * cell)
	var rel = mouse_local - origin
	return rel.x < 0 or rel.y < 0 or rel.x >= board_size.x or rel.y >= board_size.y

func posicao_valida(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < TAMANHO_TABULEIRO and pos.y >= 0 and pos.y < TAMANHO_TABULEIRO

func posicao_vazia(pos: Vector2) -> bool:
	return tabuleiro[pos.y][pos.x] == 0

func pecas_inimigas(pos: Vector2) -> bool:
	var valor_peca = tabuleiro[pos.y][pos.x]
	if valor_peca == 0: return false
	return (valor_peca > 0) != brancas
