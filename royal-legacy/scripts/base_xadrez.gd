extends Sprite2D

#Tabuleiro
const BOARD_SIZE = 8
const CELL_WIDTH = 18.0
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

const TURNO_BRANCO = preload("uid://0q5rfk1gwkau")
const TURNO_PRETO = preload("uid://op3kil5srww7")
const MOVIMENTACAO_PECA = preload("uid://miyycfpemav1")


@onready var pecas: Node2D = $pecas
@onready var quadrados: Node2D = $quadrados
@onready var turno: Node2D = $turno

var tabuleiro: Array = []
var brancas: bool
var situacao: bool
var movimento = []
var selecionar_peca: Vector2

func _ready():
	tabuleiro.append([4, 2, 3, 5, 6, 3, 2, 4])
	tabuleiro.append([1, 1, 1, 1, 1, 1, 1, 1])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([0, 0, 0, 0, 0, 0, 0, 0])
	tabuleiro.append([-1, -1, -1, -1, -1, -1, -1, -1])
	tabuleiro.append([-4, -2, -3, -5, -6, -3, -2, -4])
	
	exibir()
	
	
func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_off(): return
			var var1 = snapped(get_local_mouse_position().x, 0) / CELL_WIDTH
			var var2 = abs(snapped(get_local_mouse_position().y, 0)) / CELL_WIDTH
			if !situacao && (brancas && tabuleiro[var2][var1] > 0 || !brancas && tabuleiro[var2][var1] < 0):
				mostrar_opcoes()
				selecionar_peca = Vector2(var2, var1)
				situacao = true
			
func mouse_off() -> bool:
	var mouse = get_local_mouse_position()
	return mouse.x < 0 or mouse.x > BOARD_SIZE * CELL_WIDTH or mouse.y > 0 or mouse.y < -BOARD_SIZE * CELL_WIDTH
	
func exibir():
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var casa = CASAS.instantiate()
			pecas.add_child(casa)
			casa.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2), -i * CELL_WIDTH - (CELL_WIDTH / 2))
			
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

func mostrar_quadrados():
	for i in movimento:
		var casa = CASAS.instantiate()
		quadrados.add_child(casa)
		casa.texture = MOVIMENTACAO_PECA
		casa.global_position = Vector2(i.y * CELL_WIDTH + (CELL_WIDTH / 2), -i.x * CELL_WIDTH - (CELL_WIDTH / 2))
		

func pegar_movimento():
	pass
