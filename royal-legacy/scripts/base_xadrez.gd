extends Sprite2D

# ==========================
#   CONSTANTES E PRELOADS
# ==========================

const TAMANHO_TABULEIRO = 8
const TAMANHO_CELULA = 18.0
const CASAS = preload("uid://c8snr6qequ51c")
const BISPO_BRANCO = preload("uid://dmw5aco5mr0ot")
const BISPO_PRETO = preload("uid://6ypo2afls06u")
const CAVALO_BRANCO = preload("uid://33s58ruwmk72")
const CAVALO_PRETO = preload("uid://bn1cp7pl06r7i")
const PEAO_BRANCO = preload("uid://bqbg07hivfpne")
const PEAO_PRETO = preload("uid://yd5g0e6so2aa")
const RAINHA_BRANCA = preload("uid://b5uvwhds6d428")
const RAINHA_PRETA = preload("uid://b44u3s5yucep5")
const REI_BRANCO = preload("uid://dpmnx7e7b7ie2")
const REI_PRETO = preload("uid://cunta3rxnil1q")
const TORRE_BRANCA = preload("uid://dl0x2md5aj6vp")
const TORRE_PRETA = preload("uid://bv3u6gc45fxpj")
const MOVIMENTACAO_PECA = preload("uid://miyycfpemav1")

# ==========================
#        NÓS DO CENÁRIO
# ==========================

@onready var pecas: Node2D = $pecas
@onready var quadrados: Node2D = $quadrados

# ==========================
#        VARIÁVEIS
# ==========================

var tabuleiro: Array = []
var brancas: bool = true
var situacao: bool = false
var movimento = []
var selecionar_peca: Vector2

# ==========================
#   FUNÇÃO PRINCIPAL (_ready)
# ==========================

func _ready():
	tabuleiro.append([-4, -2, -3, -5, -6, -3, -2, -4])
	tabuleiro.append([-1, -1, -1, -1, -1, -1, -1, -1])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([1, 1, 1, 1, 1, 1, 1, 1])
	tabuleiro.append([4, 2, 3, 5, 6, 3, 2, 4])
	exibir()

# ==========================
#     INPUT DO MOUSE
# ==========================

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
		if mouse_off(): return

		var mouse = get_local_mouse_position()
		var coluna = floor(mouse.x / TAMANHO_CELULA)
		var linha = floor(mouse.y / TAMANHO_CELULA)

		if !situacao && ((brancas && tabuleiro[linha][coluna] > 0) || (!brancas && tabuleiro[linha][coluna] < 0)):
			selecionar_peca = Vector2(coluna, linha)
			mostrar_opcoes()
			situacao = true
		elif situacao:
			definir_movimento(linha, coluna)

# ==========================
#   LÓGICA DE MOVIMENTO
# ==========================

func definir_movimento(linha, coluna):
	var movimento_encontrado = false
	for i in movimento:
		if i.y == linha && i.x == coluna:
			movimento_encontrado = true
			break

	# Limpa os quadrados de highlight
	for child in quadrados.get_children():
		child.queue_free()
		situacao = false

	if movimento_encontrado:
		# Executa o movimento
		tabuleiro[linha][coluna] = tabuleiro[selecionar_peca.y][selecionar_peca.x]
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
		
		# Passa o turno
		brancas = !brancas
		
		# Verifica o estado do jogo
		verificar_fim_de_jogo()
		
		exibir()

func mostrar_opcoes():
	movimento = pegar_movimento()
	if movimento.is_empty():
		situacao = false
		return
	mostrar_quadrados()

func pegar_movimento():
	var _movimento = []
	match abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]):
		1: _movimento = peao_movimento()
		2: _movimento = cavalo_movimento()
		3: _movimento = bispo_movimento()
		4: _movimento = torre_movimento()
		5: _movimento = rainha_movimento()
		6: _movimento = rei_movimento()
	return _movimento

# ==========================
#   MOVIMENTOS DAS PEÇAS
# ==========================

func peao_movimento():
	var _movimento = []
	var direcao = 1 if !brancas else -1
	var pos = selecionar_peca + Vector2(0, direcao)

	# Movimento para frente
	if posicao_valida(pos) && posicao_vazia(pos):
		_movimento.append(pos)
		# Movimento duplo
		var primeira_jogada = (brancas && selecionar_peca.y == 6) || (!brancas && selecionar_peca.y == 1)
		if primeira_jogada:
			pos = selecionar_peca + Vector2(0, direcao * 2)
			if posicao_valida(pos) && posicao_vazia(pos):
				_movimento.append(pos)

	# Captura
	for i in [-1, 1]:
		pos = selecionar_peca + Vector2(i, direcao)
		if posicao_valida(pos) && !posicao_vazia(pos) && pecas_inimigas(pos):
			_movimento.append(pos)

	return filtrar_movimentos_ilegais(_movimento)

func cavalo_movimento():
	var _movimento = []
	var direcoes = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos) && (posicao_vazia(pos) || pecas_inimigas(pos)):
			_movimento.append(pos)
	return filtrar_movimentos_ilegais(_movimento)

func torre_movimento():
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]))

func bispo_movimento():
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]))

func rainha_movimento():
	return filtrar_movimentos_ilegais(movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]))

func rei_movimento():
	var _movimento = []
	var direcoes = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	for d in direcoes:
		var pos = selecionar_peca + d
		if posicao_valida(pos) && (posicao_vazia(pos) || pecas_inimigas(pos)):
			_movimento.append(pos)
	return filtrar_movimentos_ilegais(_movimento)

func movimento_linear(direcoes):
	var _movimento = []
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

func filtrar_movimentos_ilegais(movimentos):
	var movimentos_legais = []
	for m in movimentos:
		# Simula o movimento
		var peca_origem = tabuleiro[selecionar_peca.y][selecionar_peca.x]
		var peca_destino = tabuleiro[m.y][m.x]
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
		tabuleiro[m.y][m.x] = peca_origem

		if !esta_em_xeque(brancas):
			movimentos_legais.append(m)

		# Desfaz o movimento
		tabuleiro[selecionar_peca.y][selecionar_peca.x] = peca_origem
		tabuleiro[m.y][m.x] = peca_destino
	return movimentos_legais

func esta_em_xeque(cor_rei: bool):
	var pos_rei = encontrar_rei(cor_rei)
	if pos_rei == Vector2.ONE * -1: return false
	return casa_sob_ataque(pos_rei, !cor_rei)

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
			var peca_cor = tabuleiro[y][x] > 0
			if tabuleiro[y][x] != 0 && peca_cor == cor_atacante:
				var movimentos_brutos = pegar_movimentos_brutos(Vector2(x, y))
				for m in movimentos_brutos:
					if m == pos:
						return true
	return false

func pegar_movimentos_brutos(pos_peca: Vector2):
	var temp_selecionar_peca = selecionar_peca
	var temp_brancas = brancas
	selecionar_peca = pos_peca
	brancas = tabuleiro[pos_peca.y][pos_peca.x] > 0
	
	var _movimento = []
	match abs(tabuleiro[pos_peca.y][pos_peca.x]):
		1: _movimento = peao_movimento_bruto()
		2: _movimento = cavalo_movimento_bruto()
		3: _movimento = bispo_movimento_bruto()
		4: _movimento = torre_movimento_bruto()
		5: _movimento = rainha_movimento_bruto()
		6: _movimento = rei_movimento_bruto()

	selecionar_peca = temp_selecionar_peca
	brancas = temp_brancas
	return _movimento

func verificar_fim_de_jogo():
	var tem_movimento_legal = false
	for y in range(TAMANHO_TABULEIRO):
		for x in range(TAMANHO_TABULEIRO):
			var peca_cor = tabuleiro[y][x] > 0
			if tabuleiro[y][x] != 0 && peca_cor == brancas:
				selecionar_peca = Vector2(x, y)
				if !pegar_movimento().is_empty():
					tem_movimento_legal = true
					break
		if tem_movimento_legal:
			break

	if !tem_movimento_legal:
		var game_manager = get_node("/root/GameManager")
		if esta_em_xeque(brancas):
			game_manager.end_game(1) # Xeque-mate
		else:
			game_manager.end_game(2) # Empate

# ==========================
#   MOVIMENTOS BRUTOS (para checagem de ataque)
# ==========================

func peao_movimento_bruto():
	var _movimento = []
	var direcao = 1 if !brancas else -1
	for i in [-1, 1]:
		var pos = selecionar_peca + Vector2(i, direcao)
		_movimento.append(pos)
	return _movimento

func cavalo_movimento_bruto():
	var _movimento = []
	var direcoes = [Vector2(1,2),Vector2(1,-2),Vector2(-1,2),Vector2(-1,-2),Vector2(2,1),Vector2(2,-1),Vector2(-2,1),Vector2(-2,-1)]
	for d in direcoes:
		_movimento.append(selecionar_peca + d)
	return _movimento

func torre_movimento_bruto():
	return movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)])

func bispo_movimento_bruto():
	return movimento_linear([Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])

func rainha_movimento_bruto():
	return movimento_linear([Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)])

func rei_movimento_bruto():
	var _movimento = []
	var direcoes = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1),Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]
	for d in direcoes:
		_movimento.append(selecionar_peca + d)
	return _movimento

# ==========================
#   FUNÇÕES DE EXIBIÇÃO E UTILITÁRIAS
# ==========================

func exibir():
	# Limpa as peças antigas
	for child in pecas.get_children():
		child.queue_free()
		
	for i in range(TAMANHO_TABULEIRO):
		for j in range(TAMANHO_TABULEIRO):
			var casa = CASAS.instantiate()
			pecas.add_child(casa)
			casa.global_position = Vector2(j * TAMANHO_CELULA + (TAMANHO_CELULA / 2), i * TAMANHO_CELULA + (TAMANHO_CELULA / 2))
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

func mostrar_quadrados():
	for i in movimento:
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = MOVIMENTACAO_PECA
		casa.global_position = Vector2(i.x * TAMANHO_CELULA + (TAMANHO_CELULA / 2), i.y * TAMANHO_CELULA + (TAMANHO_CELULA / 2))

func mouse_off() -> bool:
	var mouse = get_local_mouse_position()
	return mouse.x < 0 || mouse.x > TAMANHO_TABULEIRO * TAMANHO_CELULA || mouse.y < 0 || mouse.y > TAMANHO_TABULEIRO * TAMANHO_CELULA

func posicao_valida(pos: Vector2) -> bool:
	return pos.x >= 0 && pos.x < TAMANHO_TABULEIRO && pos.y >= 0 && pos.y < TAMANHO_TABULEIRO

func posicao_vazia(pos: Vector2) -> bool:
	return tabuleiro[pos.y][pos.x] == 0

func pecas_inimigas(pos: Vector2) -> bool:
	var valor_peca = tabuleiro[pos.y][pos.x]
	if valor_peca == 0: return false
	return (valor_peca > 0) != brancas
