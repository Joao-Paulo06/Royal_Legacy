extends Sprite2D

# ==========================
#   CONSTANTES E PRELOADS
# ==========================

# Tamanho do tabuleiro (8x8)
const TAMANHO_TABULEIRO = 8

# Tamanho de cada célula do tabuleiro em pixels
const TAMANHO_CELULA = 18.0

# Cena base usada como "casa" (sprite onde são colocadas as peças)
const CASAS = preload("uid://c8snr6qequ51c")

# Peças do jogo – cada preload carrega uma textura
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
# Texturas usadas para indicar turno e casas possíveis
const TURNO_BRANCO = preload("uid://0q5rfk1gwkau")
const TURNO_PRETO = preload("uid://op3kil5srww7")
const MOVIMENTACAO_PECA = preload("uid://miyycfpemav1")

# ==========================
#        NÓS DO CENÁRIO
# ==========================

# Nó onde as peças são exibidas
@onready var pecas: Node2D = $pecas

# Nó onde quadrados de movimento (highlight) aparecem
@onready var quadrados: Node2D = $quadrados

# Indicação visual do turno
@onready var turno: Node2D = $turno

# ==========================
#        VARIÁVEIS
# ==========================

# Matriz que representa o tabuleiro (8x8)
# Números positivos = peças brancas
# Números negativos = peças pretas
var tabuleiro: Array = []

# Quem joga — true = brancas, false = pretas
var brancas: bool = true

# Indica se já existe uma peça selecionada para mover
var situacao: bool = false

# Lista dos movimentos possíveis da peça selecionada
var movimento = []

# Posição da peça atualmente selecionada
var selecionar_peca: Vector2

# ==========================
#   FUNÇÃO PRINCIPAL (_ready)
# ==========================

func _ready():
	# Prepara o tabuleiro inicial usando números
	tabuleiro.append([-4, -2, -3, -5, -6, -3, -2, -4])   # Linha das peças pretas
	tabuleiro.append([-1, -1, -1, -1, -1, -1, -1, -1])   # Peões pretos
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])           # Linhas vazias
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])           # Vazio
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])           # Vazio
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])           # Vazio
	tabuleiro.append([1, 1, 1, 1, 1, 1, 1, 1])           # Peões brancos
	tabuleiro.append([4, 2, 3, 5, 6, 3, 2, 4])           # Linha das peças brancas

	# Exibe todas as peças iniciais na tela
	exibir()

# ==========================
#     INPUT DO MOUSE
# ==========================

func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:

			# Se clicou fora do tabuleiro, ignora
			if mouse_off(): return

			# Converte posição do mouse → coordenadas do tabuleiro
			var mouse = get_local_mouse_position()
			var coluna = floor(mouse.x / TAMANHO_CELULA)
			var linha = floor(mouse.y / TAMANHO_CELULA)

			# Se ainda não há peça selecionada
			if !situacao && (
				(brancas && tabuleiro[linha][coluna] > 0) || 
				(!brancas && tabuleiro[linha][coluna] < 0)
			):
				# Salva a peça selecionada
				selecionar_peca = Vector2(coluna, linha)

				# Mostra os movimentos possíveis
				mostrar_opcoes()

				situacao = true  # Marca como "já existe uma peça selecionada"
			
			elif situacao: definir_movimento(linha, coluna)
# ==========================
# FUNÇÃO: VERIFICA SE CLICOU FORA
# ==========================

func mouse_off() -> bool:
	var mouse = get_local_mouse_position()
	return (
		mouse.x < 0 ||
		mouse.x > TAMANHO_TABULEIRO * TAMANHO_CELULA ||
		mouse.y < 0 ||
		mouse.y > TAMANHO_TABULEIRO * TAMANHO_CELULA
	)

# ==========================
# EXIBE TODAS AS PEÇAS
# ==========================

func exibir():
	# Percorre o tabuleiro 8x8
	for i in range(TAMANHO_TABULEIRO):
		for j in range(TAMANHO_TABULEIRO):

			# Instancia um sprite (casa)
			var casa = CASAS.instantiate()
			pecas.add_child(casa)

			# Posiciona no tabuleiro
			casa.global_position = Vector2(
				j * TAMANHO_CELULA + (TAMANHO_CELULA / 2),
				i * TAMANHO_CELULA + (TAMANHO_CELULA / 2)
			)

			# Define a textura conforme o valor da peça
			match tabuleiro[i][j]:
				-6: casa.texture = REI_PRETO  
				-5: casa.texture = RAINHA_PRETA 
				-4: casa.texture = TORRE_PRETA 
				-3: casa.texture = BISPO_PRETO 
				-2: casa.texture = CAVALO_PRETO 
				-1: casa.texture = PEAO_PRETO
				0: casa.texture = null  
				6: casa.texture = REI_BRANCO
				5: casa.texture = RAINHA_BRANCA 
				4: casa.texture = TORRE_BRANCA
				3: casa.texture = BISPO_BRANCO
				2: casa.texture = CAVALO_BRANCO
				1: casa.texture = PEAO_BRANCO

# ==========================
# MOSTRA OPÇÕES DE MOVIMENTO
# ==========================

func mostrar_opcoes():
	movimento = pegar_movimento()

	# Se não houver movimentos possíveis, deseleciona
	if movimento == []:
		situacao = false
		return

	mostrar_quadrados()

# Exibe quadrados de highlight nas casas possíveis
func mostrar_quadrados():
	for i in movimento:
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = MOVIMENTACAO_PECA
		casa.global_position = Vector2(
			i.x * TAMANHO_CELULA + (TAMANHO_CELULA / 2),
			i.y * TAMANHO_CELULA + (TAMANHO_CELULA / 2)
		)

# ==========================
# FUNÇÃO PRINCIPAL DE MOVIMENTO
# ==========================

func pegar_movimento():
	var _movimento = []

	# Detecta qual tipo de peça está selecionada (abs remove sinal branco/preto)
	match abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]):
		1: _movimento = peao_movimento()
		2: _movimento = cavalo_movimento()
		3: _movimento = bispo_movimento()
		4: _movimento = torre_movimento()
		5: _movimento = rainha_movimento()
		6: _movimento = rei_movimento()
	
	return _movimento
	
func definir_movimento(linha, coluna):
	for i in movimento:
		if i.y == linha && i.x == coluna:
			tabuleiro[linha][coluna] = tabuleiro[selecionar_peca.y][selecionar_peca.x]
			tabuleiro[selecionar_peca.y][selecionar_peca.x] = 0
			brancas = !brancas
			exibir()
			
# ==========================
# MOVIMENTO DO PEÃO
# ==========================

func peao_movimento():
	var _movimento = []
	var direcao
	var primeiro_movimento = false
	
	# Define direção do peão
	if brancas: direcao = Vector2(0, -1)
	else: direcao = Vector2(0, 1)
	
	# Verifica se está na linha inicial
	if (brancas && selecionar_peca.y == 6) || (!brancas && selecionar_peca.y == 1):
		primeiro_movimento = true
	
	# Movimento simples de 1 casa
	var pos = selecionar_peca + direcao
	if posicao_valida(pos) && posicao_vazia(pos):
		_movimento.append(pos)
	
	# Captura na diagonal (direita)
	pos = selecionar_peca + Vector2(1, direcao.y)
	if posicao_valida(pos) && pecas_inimigas(pos):
		_movimento.append(pos)

	# Captura na diagonal (esquerda)
	pos = selecionar_peca + Vector2(-1, direcao.y)
	if posicao_valida(pos) && pecas_inimigas(pos):
		_movimento.append(pos)
	
	# Movimento duplo no primeiro lance
	pos = selecionar_peca + direcao * 2
	if primeiro_movimento && posicao_vazia(pos) && posicao_vazia(selecionar_peca + direcao):
		_movimento.append(pos)
	
	return _movimento

# ==========================
# MOVIMENTO DO CAVALO
# ==========================

func cavalo_movimento():
	var _movimento = []
	var direcao = [
		Vector2(2, 1), Vector2(2, -1),
		Vector2(-2, 1), Vector2(-2, -1),
		Vector2(1, 2), Vector2(1, -2),
		Vector2(-1, 2), Vector2(-1, -2)
	]
	
	for i in direcao:
		var pos = selecionar_peca + i
		
		if posicao_valida(pos):
			if posicao_vazia(pos):
				_movimento.append(pos)
			elif pecas_inimigas(pos):
				_movimento.append(pos)
				
	return _movimento

# ==========================
# MOVIMENTO DA TORRE
# ==========================

func torre_movimento():
	var _movimento = []
	var direcao = [
		Vector2(1, 0), Vector2(-1, 0),
		Vector2(0, 1), Vector2(0, -1)
	]
	
	for i in direcao:

		# Começa andando 1 casa na direção
		var pos = selecionar_peca + i
		
		while posicao_valida(pos):
			if posicao_vazia(pos):
				_movimento.append(pos)
			elif pecas_inimigas(pos):
				_movimento.append(pos)
				break
			else:
				break
			
			pos += i  # Continua andando
		
	return _movimento

# ==========================
# MOVIMENTO DO BISPO
# ==========================

func bispo_movimento():
	var _movimento = []
	var direcao = [
		Vector2(1, 1), Vector2(1, -1),
		Vector2(-1, 1), Vector2(-1, -1)
	]
	
	for i in direcao:
		var pos = selecionar_peca + i

		while posicao_valida(pos):
			if posicao_vazia(pos):
				_movimento.append(pos)
			elif pecas_inimigas(pos):
				_movimento.append(pos)
				break
			else:
				break
			
			pos += i

	return _movimento

# ==========================
# MOVIMENTO DA RAINHA
# ==========================

func rainha_movimento():
	var _movimento = []
	var direcao = [
		Vector2(1, 1), Vector2(1, -1),
		Vector2(-1, 1), Vector2(-1, -1),

		Vector2(1, 0), Vector2(-1, 0),
		Vector2(0, 1), Vector2(0, -1)
	]
	
	for i in direcao:
		var pos = selecionar_peca + i
		
		while posicao_valida(pos):
			if posicao_vazia(pos):
				_movimento.append(pos)
			elif pecas_inimigas(pos):
				_movimento.append(pos)
				break
			else:
				break
			
			pos += i

	return _movimento

# ==========================
# MOVIMENTO DO REI
# ==========================

func rei_movimento():
	var _movimento = []
	var direcao = [
		Vector2(1, 1), Vector2(1, -1),
		Vector2(-1, 1), Vector2(-1, -1),
		Vector2(1, 0), Vector2(-1, 0),
		Vector2(0, 1), Vector2(0, -1)
	]
	
	for i in direcao:
		var pos = selecionar_peca + i
		
		if posicao_valida(pos):
			if posicao_vazia(pos):
				_movimento.append(pos)
			elif pecas_inimigas(pos):
				_movimento.append(pos)
				
	return _movimento

# ==========================
# FUNÇÕES ÚTEIS
# ==========================

# Verifica se está dentro do tabuleiro
func posicao_valida(pos: Vector2):
	return pos.x >= 0 && pos.x < TAMANHO_TABULEIRO && pos.y >= 0 && pos.y < TAMANHO_TABULEIRO

# Verifica se a casa está vazia
func posicao_vazia(pos: Vector2):
	return tabuleiro[pos.y][pos.x] == 0

# Verifica se é uma peça inimiga
func pecas_inimigas(pos: Vector2):
	if brancas:
		return tabuleiro[pos.y][pos.x] < 0
	else:
		return tabuleiro[pos.y][pos.x] > 0
