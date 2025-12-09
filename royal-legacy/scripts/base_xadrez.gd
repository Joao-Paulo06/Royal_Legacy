extends Sprite2D

# ==========================
#   CONSTANTES E PRELOADS
# ==========================

const TAMANHO_TABULEIRO := 8
const TAMANHO_CELULA := 60.0  # fallback se a textura não estiver disponível
const CASAS := preload("uid://c8snr6qequ51c")
const BISPO_BRANCO = preload("uid://tsrh843l2ycr")
const BISPO_PRETO = preload("uid://dvwybgmrfmhoe")
const CAVALO_BRANCO = preload("uid://t1gw66fhf5sv")
const CAVALO_PRETO = preload("uid://52hwqs8up4f7")
const MOVIMENTACAO_PECA = preload("uid://dsbd2dsi7qewt")
const PEAO_BRANCO = preload("uid://61eaf3bd4usa")
const PEAO_PRETO = preload("uid://bmmlr62nw3txa")
const RAINHA_BRANCA = preload("uid://fuyoj0eebx58")
const RAINHA_PRETA = preload("uid://d2ej8vtypvfhs")
const REI_BRANCO = preload("uid://dbrigkc20j5jy")
const REI_PRETO = preload("uid://cxsmjhjlpdlyk")
const TORRE_BRANCA = preload("uid://uiwrboynrvyt")
const TORRE_PRETA = preload("uid://s10ect4l8h2u")
const TURNO_BRANCO = preload("uid://b1pe1tl2cow1w")
const TURNO_PRETO = preload("uid://djkjehjg6jdq2")
const SOM_CAPTURANDO = preload("uid://b7rtga1jwlm4s")
const SOM_MOVIMENTO = preload("uid://dg3r16ow1l3vb")


# ==========================
#        NÓS DO CENÁRIO
# ==========================

@onready var pecas: Node2D = $pecas
@onready var quadrados: Node2D = $quadrados
@onready var turno: Sprite2D = $turno
@onready var check_indicator: ColorRect = $CheckIndicator
@onready var som_pecas: AudioStreamPlayer = $Som_pecas


# ==========================
#        VARIÁVEIS
# ==========================

var tabuleiro: Array = []
var brancas: bool = true            # turno das brancas (true) ou pretas (false)
var situacao: bool = false          # se está no modo "peça selecionada"
var movimento: Array = []          # movimentos válidos da peça selecionada
var selecionar_peca: Vector2 = Vector2(-1, -1)  # posição da peça selecionada

# ==========================
#   FUNÇÃO PRINCIPAL (_ready)
# ==========================

func _ready() -> void:
	# Conecta o sinal de xeque do GameManager
	var game_manager = get_node("../tabuleiro/GameManager")
	if game_manager:
		game_manager.check_state_changed.connect(_on_check_state_changed)


	# Inicializa tabuleiro padrão
	# valores positivos = peças brancas, negativos = peças pretas
	tabuleiro = [
		[-4, -2, -3, -5, -6, -3, -2, -4],
		[-1, -1, -1, -1, -1, -1, -1, -1],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[1, 1, 1, 1, 1, 1, 1, 1],
		[4, 2, 3, 5, 6, 3, 2, 4]
	]
	exibir()

# ==========================
#     UTILITÁRIOS DO TABULEIRO
# ==========================

func _get_texture() -> Texture2D:
	return texture

func _get_texture_size() -> Vector2:
	var tex = _get_texture()
	if tex == null:
		return Vector2.ZERO
	return tex.get_size()

func _get_cell_size() -> float:
	# calcula o tamanho da célula com base na largura da textura
	var tex_size = _get_texture_size()
	if tex_size.x == 0:
		return TAMANHO_CELULA # fallback
	return tex_size.x / float(TAMANHO_TABULEIRO)

func _get_board_origin() -> Vector2:
	# retorna o canto superior esquerdo do tabuleiro em coordenadas locais
	var tex_size = _get_texture_size()
	if centered:
		return -tex_size * 0.5
	else:
		return Vector2.ZERO

# verifica se o mouse está fora do tabuleiro (usando coordenadas locais da Sprite2D)
func mouse_off() -> bool:
	var mouse_local = to_local(get_global_mouse_position())
	var origin = _get_board_origin()
	var cell = _get_cell_size()
	var board_size = Vector2(TAMANHO_TABULEIRO * cell, TAMANHO_TABULEIRO * cell)
	var rel = mouse_local - origin
	return rel.x < 0 or rel.y < 0 or rel.x >= board_size.x or rel.y >= board_size.y

# ==========================
#        INPUT DO MOUSE
# ==========================

func _input(event) -> void:
	# somente clique esquerdo pressionado
	if not (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		return

	# posição do mouse em coordenadas locais da sprite
	var mouse_local = to_local(get_global_mouse_position())
	var origin = _get_board_origin()
	var cell = _get_cell_size()

	# mouse relativo ao canto superior esquerdo do tabuleiro (em pixels da textura)
	var mouse_board = mouse_local - origin

	# checar se está dentro do tabuleiro
	if mouse_board.x < 0 or mouse_board.x >= TAMANHO_TABULEIRO * cell:
		return
	if mouse_board.y < 0 or mouse_board.y >= TAMANHO_TABULEIRO * cell:
		return

	var coluna := int(floor(mouse_board.x / cell))
	var linha := int(floor(mouse_board.y / cell))

	# seleção e movimento
	if not situacao and ((brancas and tabuleiro[linha][coluna] > 0) or (not brancas and tabuleiro[linha][coluna] < 0)):
		selecionar_peca = Vector2(coluna, linha)
		mostrar_opcoes()
		situacao = true
	elif situacao:
		definir_movimento(linha, coluna)

# ==========================
#   LÓGICA DE MOVIMENTO
# ==========================

func definir_movimento(linha: int, coluna: int) -> void:
	var movimento_encontrado := false
	for i in movimento:
		if i.y == linha and i.x == coluna:
			movimento_encontrado = true
			break

	# limpa indicadores de movimento
	for child in quadrados.get_children():
		child.queue_free()
	situacao = false

	if movimento_encontrado:
			# executa movimento
			var peca_destino_valor = tabuleiro[linha][coluna] # Valor da peça na casa de destino (0 se vazia)
			
			tabuleiro[linha][coluna] = tabuleiro[selecionar_peca.y][selecionar_peca.x]
			tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
			
			# Toca o som apropriado
			if peca_destino_valor != 0:
				tocar_som(SOM_CAPTURANDO)
			else:
				tocar_som(SOM_MOVIMENTO)
				
			brancas = not brancas
			verificar_fim_de_jogo()
			exibir()

# ==========================
#        ÁUDIO
# ==========================

func tocar_som(som: AudioStream) -> void:
	if som_pecas:
		som_pecas.stream = som
		som_pecas.play()

# ==========================
#   LÓGICA DE MOVIMENTO
# ==========================

func mostrar_opcoes() -> void:
	movimento = pegar_movimento()
	if movimento.is_empty():
		situacao = false
		return
	mostrar_quadrados()

func pegar_movimento() -> Array:
	var _movimento: Array = []
	match abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]):
		1:
			_movimento = peao_movimento()
		2:
			_movimento = cavalo_movimento()
		3:
			_movimento = bispo_movimento()
		4:
			_movimento = torre_movimento()
		5:
			_movimento = rainha_movimento()
		6:
			_movimento = rei_movimento()
	return _movimento

# ==========================
#   MOVIMENTOS DAS PEÇAS
# ==========================

func peao_movimento() -> Array:
	var _movimento: Array = []
	var direcao := 1 if not brancas else -1
	var pos := selecionar_peca + Vector2(0, direcao)

	# avanço simples e duplo na primeira jogada
	if posicao_valida(pos) and posicao_vazia(pos):
		_movimento.append(pos)
		var primeira_jogada := (brancas and selecionar_peca.y == 6) or (not brancas and selecionar_peca.y == 1)
		if primeira_jogada:
			pos = selecionar_peca + Vector2(0, direcao * 2)
			if posicao_valida(pos) and posicao_vazia(pos):
				_movimento.append(pos)

	# capturas diagonais
	for i in [-1, 1]:
		pos = selecionar_peca + Vector2(i, direcao)
		if posicao_valida(pos) and not posicao_vazia(pos) and pecas_inimigas(pos):
			_movimento.append(pos)

	return filtrar_movimentos_ilegais(_movimento)

func cavalo_movimento() -> Array:
	var _movimento: Array = []
	var direcoes = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
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
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]))

func rei_movimento() -> Array:
	var _movimento: Array = []
	var direcoes = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos) and (posicao_vazia(pos) or pecas_inimigas(pos)):
			_movimento.append(pos)
	return filtrar_movimentos_ilegais(_movimento)

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

# ==========================
#   LÓGICA DE XEQUE E XEQUE-MATE
# ==========================

func filtrar_movimentos_ilegais(movimentos: Array) -> Array:
	var movimentos_legais: Array = []
	for m in movimentos:
		var peca_origem = tabuleiro[selecionar_peca.y][selecionar_peca.x]
		var peca_destino = tabuleiro[m.y][m.x]
		# aplica movimento temporariamente
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
		tabuleiro[m.y][m.x] = peca_origem

		if not esta_em_xeque(brancas):
			movimentos_legais.append(m)

		# restaura tabuleiro
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = peca_origem
		tabuleiro[m.y][m.x] = peca_destino
	return movimentos_legais

func esta_em_xeque(cor_rei: bool) -> bool:
	var pos_rei = encontrar_rei(cor_rei)
	if pos_rei == Vector2.ONE * -1:
		return false
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
			if peca_valor == 0:
				continue
			var peca_cor_branca = peca_valor > 0
			if peca_cor_branca == cor_atacante:
				var movimentos_brutos = pegar_movimentos_brutos(Vector2(x, y))
				for m in movimentos_brutos:
					if m == pos:
						return true
	return false

func pegar_movimentos_brutos(pos_peca: Vector2) -> Array:
	# salva estado atual
	var temp_selecionar_peca = selecionar_peca
	var temp_brancas = brancas

	selecionar_peca = pos_peca
	brancas = tabuleiro[pos_peca.y][pos_peca.x] > 0

	var _movimento: Array = []
	match abs(tabuleiro[pos_peca.y][pos_peca.x]):
		1:
			_movimento = peao_movimento_bruto()
		2:
			_movimento = cavalo_movimento_bruto()
		3:
			_movimento = movimento_linear_bruto([Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])
		4:
			_movimento = movimento_linear_bruto([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)])
		5:
			_movimento = movimento_linear_bruto([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])
		6:
			_movimento = rei_movimento_bruto()

	# restaura estado
	selecionar_peca = temp_selecionar_peca
	brancas = temp_brancas
	return _movimento

func verificar_fim_de_jogo() -> void:
	var tem_movimento_legal = false
	var pecas_jogador_atual: Array = []
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var peca_valor = tabuleiro[y][x]
			if peca_valor != 0 and (peca_valor > 0) == brancas:
				pecas_jogador_atual.append(Vector2(x,y))

	var temp_selecionar_peca = selecionar_peca
	for p in pecas_jogador_atual:
		selecionar_peca = p
		if not pegar_movimento().is_empty():
			tem_movimento_legal = true
			break
	selecionar_peca = temp_selecionar_peca

	if not tem_movimento_legal:
		var game_manager = get_node("../tabuleiro/GameManager")
		if esta_em_xeque(brancas):
			game_manager.end_game(1) # Xeque-mate
		else:
			game_manager.end_game(2) # Empate

# ==========================
#   MOVIMENTOS BRUTOS (para checagem de ataque)
# ==========================

func movimento_linear_bruto(direcoes: Array) -> Array:
	var _movimento: Array = []
	for d in direcoes:
		var pos = selecionar_peca + d
		while posicao_valida(pos):
			_movimento.append(pos)
			if not posicao_vazia(pos):
				break
			pos += d
	return _movimento

func peao_movimento_bruto() -> Array:
	var _movimento: Array = []
	var direcao := 1 if not brancas else -1
	for i in [-1, 1]:
		var pos = selecionar_peca + Vector2(i, direcao)
		if posicao_valida(pos):
			_movimento.append(pos)
	return _movimento

func cavalo_movimento_bruto() -> Array:
	var _movimento: Array = []
	var direcoes = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos):
			_movimento.append(pos)
	return _movimento

func rei_movimento_bruto() -> Array:
	var _movimento: Array = []
	var direcoes = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos):
			_movimento.append(pos)
	return _movimento

# ==========================
#   FUNÇÕES DE EXIBIÇÃO E UTILITÁRIAS
# ==========================

func _on_check_state_changed(is_in_check: bool) -> void:
	if is_in_check:
		# Efeito de piscar vermelho no tabuleiro
		var tween = check_indicator.create_tween()
		tween.set_loops()
		tween.tween_property(check_indicator, "color", Color(1, 0, 0, 0.2), 0.5)
		tween.tween_property(check_indicator, "color", Color(1, 0, 0, 0.0), 0.5)
	else:
		# Para o efeito de piscar e garante que a cor está transparente
		check_indicator.get_tree().create_tween().kill()
		check_indicator.color = Color(1, 0, 0, 0)

func exibir() -> void:
	# limpa peças anteriores
	for child in pecas.get_children():
		child.queue_free()

	var origin = _get_board_origin()
	var cell = _get_cell_size()

	for i in range(TAMANHO_TABULEIRO):
		for j in range(TAMANHO_TABULEIRO):
			var casa = CASAS.instantiate()
			pecas.add_child(casa)
			# posiciona no centro da célula (em pixels da textura)
			casa.position = origin + Vector2(
				j * cell + cell * 0.5,
				i * cell + cell * 0.5
			)
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
				
				# Animação de transição de turno
			if brancas: turno.texture = TURNO_BRANCO
			else: turno.texture = TURNO_PRETO	

func mostrar_quadrados() -> void:
	# limpa e mostra indicadores de movimento
	for child in quadrados.get_children():
		child.queue_free()

	var origin = _get_board_origin()
	var cell = _get_cell_size()
	for i in movimento:
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = MOVIMENTACAO_PECA
		casa.position = origin + Vector2(
			i.x * cell + cell * 0.5,
			i.y * cell + cell * 0.5
		)

# ==========================
#   FUNÇÕES AUXILIARES
# ==========================

func posicao_valida(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < TAMANHO_TABULEIRO and pos.y >= 0 and pos.y < TAMANHO_TABULEIRO

func posicao_vazia(pos: Vector2) -> bool:
	return tabuleiro[pos.y][pos.x] == 0

func pecas_inimigas(pos: Vector2) -> bool:
	var valor_peca = tabuleiro[pos.y][pos.x]
	if valor_peca == 0:
		return false
	return (valor_peca > 0) != brancas
