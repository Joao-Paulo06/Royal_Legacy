extends Sprite2D

#Tabuleiro
const BOARD_SIZE = 8
const CELL_WIDTH = 18
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

@onready var pecas: Node2D = $pecas
@onready var quadrados: Node2D = $quadrados
@onready var turno: Node2D = $turno

var tabuleiro: Array = []
var brancas: bool
var estado: bool
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
	
	display_board()
	
func display_board():
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var casa = CASAS.instantiate()
			pecas.add_child(casa)
			casa.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2), -i * CELL_WIDTH - (CELL_WIDTH / 2))
			
			match tabuleiro[i][j]:
				-6: casa = REI_PRETO  
				-5: casa = RAINHA_PRETA 
				-4: casa = TORRE_PRETA 
				-3: casa = BISPO_PRETO 
				-2: casa = CAVALO_PRETO 
				-1: casa = PEAO_PRETO
				0: casa = null  
				6: casa = REI_BRANCO
				5: casa = RAINHA_BRANCA 
				4: casa = TORRE_BRANCA
				3: casa = BISPO_BRANCO
				2: casa = CAVALO_BRANCO
				1: casa = PEAO_BRANCO 
				
	
