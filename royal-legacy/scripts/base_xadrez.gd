extends Sprite2D

#Tabuleiro
const TAMANHO_TABULEIRO = 8
const TAMANHO_CELULA = 18.0
const CASAS = preload("uid://c8snr6qequ51c")
#Peças versão 1
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
#Sinalização
const TURNO_BRANCO = preload("uid://0q5rfk1gwkau")
const TURNO_PRETO = preload("uid://op3kil5srww7")
const MOVIMENTACAO_PECA = preload("uid://miyycfpemav1")

@onready var pecas: Node2D = $pecas
@onready var quadrados: Node2D = $quadrados
@onready var turno: Node2D = $turno

var tabuleiro: Array = []
var brancas: bool = true
var situacao: bool = false
var movimento = []
var selecionar_peca: Vector2

func _ready():
	tabuleiro.append([-4, -2, -3, -5, -6, -3, -2, -4])
	tabuleiro.append([-1, -1, -1, -1, -1, -1, -1, -1])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([4, 2, 3, 5, 6, 3, 2, 4])
	
	exibir()
	
func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_off(): return
			var mouse = get_local_mouse_position()	
			var coluna = floor(mouse.x / TAMANHO_CELULA)
			var linha = floor((mouse.y) / TAMANHO_CELULA)
			if !situacao && (brancas && tabuleiro[linha][coluna] > 0 || !brancas && tabuleiro[linha][coluna] < 0):
				selecionar_peca = Vector2(coluna, linha)
				mostrar_opcoes()
				situacao = true
			
func mouse_off() -> bool:
	var mouse = get_local_mouse_position()
	return ( 
		mouse.x < 0 
		|| mouse.x > TAMANHO_TABULEIRO * TAMANHO_CELULA 
		|| mouse.y < 0 
		|| mouse.y > TAMANHO_TABULEIRO * TAMANHO_CELULA
		)
		
func exibir():
	for i in range(TAMANHO_TABULEIRO):
		for j in range(TAMANHO_TABULEIRO):
			var casa = CASAS.instantiate()
			pecas.add_child(casa)
			casa.global_position = Vector2(
			j * TAMANHO_CELULA + (TAMANHO_CELULA / 2),
			i * TAMANHO_CELULA + (TAMANHO_CELULA / 2))
			
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

func mostrar_opcoes():
	movimento = pegar_movimento()
	if movimento == []:
		situacao = false
		return
	mostrar_quadrados()

func mostrar_quadrados():
	for i in movimento:
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = MOVIMENTACAO_PECA
		casa.global_position = Vector2(
		i.x * TAMANHO_CELULA + (TAMANHO_CELULA / 2),
		i.y * TAMANHO_CELULA + (TAMANHO_CELULA / 2))

func pegar_movimento():
	var _movimento = []
	match abs(tabuleiro[selecionar_peca.y][selecionar_peca.x]):
		1: print("peao")
		2: print("cavalo")
		3: _movimento = bispo_movimento()
		4: _movimento = torre_movimento()
		5: print("rainha")
		6: print("rei")
		
	return _movimento
	
func torre_movimento():
	var _movimento = []
	var direcao = [Vector2(1, 0), Vector2(-1, 0),Vector2(0, 1),Vector2(0, -1)]
	
	for i in direcao:
		var pos = Vector2(
				int(selecionar_peca.x) + i.x,
				int(selecionar_peca.y) + i.y
				)
		while posicao_valida(pos):
			if posicao_vazia(pos): 
				_movimento.append(pos)
			elif pecas_inimigas(pos): 
				_movimento.append(pos)
				break
			else: break
			
			pos += i

	return _movimento
	
func bispo_movimento():
	var _movimento = []
	var direcao = [Vector2(1, 1), Vector2(1, -1),Vector2(-1, 1),Vector2(-1, -1)]
	
	for i in direcao:
		var pos = Vector2(
				int(selecionar_peca.x) + i.x,
				int(selecionar_peca.y) + i.y
				)
		while posicao_valida(pos):
			if posicao_vazia(pos): 
				_movimento.append(pos)
			elif pecas_inimigas(pos): 
				_movimento.append(pos)
				break
			else: break
			
			pos += i

	return _movimento

func posicao_valida(pos: Vector2):
	if pos.x >= 0 && pos.x < TAMANHO_TABULEIRO && pos.y >= 0 && pos.y < TAMANHO_TABULEIRO: return true
	return false
	
func posicao_vazia(pos: Vector2):
	if tabuleiro[pos.y][pos.x] == 0: return true
	return false
	
func pecas_inimigas(pos: Vector2):
	if brancas && tabuleiro[pos.y][pos.x] < 0 || !brancas && tabuleiro[pos.y][pos.x] > 0: return true 
	return false
	
	
		
