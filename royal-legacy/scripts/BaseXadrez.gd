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
const BISPO_BRANCO_V_2 = preload("uid://dqwp51jl3b0ck")
const BISPO_PRETO_V_2 = preload("uid://gsw4f46g0jaa")
const CAVALO_BRANCO_V_2 = preload("uid://cgxvi1qs4yjx3")
const CAVALO_PRETO_V_2 = preload("uid://b6373wl3qw1ed")
const PEAO_BRANCO_V_2 = preload("uid://cb2bb01f1vdha")
const PEAO_PRETO_V_2 = preload("uid://nwdp0xwgkav")
const RAINHA_BRANCA_V_2 = preload("uid://bko8lwj80wnqk")
const RAINHA_PRETA_V_2 = preload("uid://djxknh4qwctcg")
const REI_BRANCO_V_2 = preload("uid://r3shp73xdycd")
const REI_PRETO_V_2 = preload("uid://d3xj2dtxa8r12")
const TORRE_BRANCA_V_2 = preload("uid://cq8b6v0oiqvy8")
const TORRE_PRETA_V_2 = preload("uid://gsxx2c4nyls8")
const BISPO_BRANCO_V_3 = preload("uid://skqxkaj1b6i2")
const BISPO_PRETO_V_3 = preload("uid://bpkaesobpavsd")
const CAVALO_BRANCO_V_3 = preload("uid://cnhs5pw0mpyg4")
const CAVALO_PRETO_V_3 = preload("uid://cqvdrw7pmtdwt")
const PEAO_BRANCO_V_3 = preload("uid://ca7kpous743qr")
const PEAO_PRETO_V_3 = preload("uid://bturaw75xwhtr")
const RAINHA_BRANCA_V_3 = preload("uid://br8t47stpbrfv")
const RAINHA_PRETA_V_3 = preload("uid://csys2q1avyu8e")
const REI_BRANCO_V_3 = preload("uid://dgl44h421l8mi")
const REI_PRETO_V_3 = preload("uid://7hjld17n62q6")
const TORRE_BRANCA_V_3 = preload("uid://4krkkosomksy")
const TORRE_PRETA_V_3 = preload("uid://caahm08xp07q2")
const BISPO_PRETO_V_4 = preload("uid://cg5bl85f506ar")
const BIXPO_BRANCO_V_4 = preload("uid://bujv0m31fic8q")
const CAVALO_BRANCO_V_4 = preload("uid://cw7smt5mpbwqx")
const CAVALO_PRETO_V_4 = preload("uid://b383jtdh167ux")
const PEAO_BRANCO_V_4 = preload("uid://c83yyvg5j0cn6")
const PEAO_PRETO_V_4 = preload("uid://bh64akl41oagj")
const RAINHA_BRANCA_V_4 = preload("uid://ceyi6oqyancdn")
const RAINHA_PRETA_V_4 = preload("uid://2w1ymn1u8gmy")
const REI_BRANCO_V_4 = preload("uid://btsrgwcxfe0io")
const REI_PRETO_V_4 = preload("uid://cd7iwngxtmgcp")
const TORRE_BRANCA_V_4 = preload("uid://biigdliefbgyh")
const TORRE_PRETA_V_4 = preload("uid://06tc7qxovryi")

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
var jogo_finalizado: bool = false
var tween_xeque: Tween
var tween_rotacao: Tween

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

# Função nativa da Godot que escuta tudo o que o jogador digita
func _unhandled_input(event):
	# Verifica se o evento foi apertar uma tecla do teclado (e não apenas segurar)
	if event is InputEventKey and event.pressed and not event.is_echo():
		
		# Se a tecla for o ESC -> Fecha o jogo
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
			
		# Se a tecla for o R -> Reinicia a cena atual (o jogo inteiro)
		elif event.keycode == KEY_R:
			get_tree().reload_current_scene()

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
		
		if not modo_pve:
			animar_rotacao_tabuleiro()
		
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
				animar_xeque_mate_tela()
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
			casa.rotation_degrees = -self.rotation_degrees
			
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
	if jogo_finalizado: 
		return # Se o jogo acabou, proíbe o amarelo de rodar!
		
	if check_indicator:
		check_indicator.visible = true
		
		# Se já tiver uma animação rodando, mata ela antes de começar outra
		if tween_xeque and tween_xeque.is_valid():
			tween_xeque.kill()
		
		tween_xeque = create_tween()
		tween_xeque.set_loops(3) # Pisca 3 vezes
		tween_xeque.tween_property(check_indicator, "color", Color(1.0, 1.0, 0.0, 0.3), 0.2)
		tween_xeque.tween_property(check_indicator, "color", Color(1.0, 1.0, 0.0, 0.0), 0.2)

func animar_xeque_mate_tela() -> void:
	jogo_finalizado = true # Avisa pro jogo inteiro que acabou!
	if check_indicator:
		check_indicator.visible = true
		
		# CANCELA o piscar amarelo na mesma hora e assume o vermelho!
		if tween_xeque and tween_xeque.is_valid():
			tween_xeque.kill()
			
		tween_xeque = create_tween()
		tween_xeque.tween_property(check_indicator, "color", Color(1.0, 0.0, 0.0, 0.6), 0.5)

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

func animar_rotacao_tabuleiro() -> void:
	# Cancela animações anteriores para não bugar se jogarem muito rápido
	if tween_rotacao and tween_rotacao.is_valid():
		tween_rotacao.kill()
		
	tween_rotacao = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Se for o turno das Brancas, a rotação é 0. Se for as Pretas, vira de ponta cabeça (180 graus)
	var rotacao_alvo = 0.0 if brancas else 180.0
	
	# 1. Anima o giro do tabuleiro (o "self")
	tween_rotacao.tween_property(self, "rotation_degrees", rotacao_alvo, 0.8)
	
	# 2. Faz as peças girarem no sentido contrário para continuarem "em pé"
	for peca in pecas.get_children():
		tween_rotacao.parallel().tween_property(peca, "rotation_degrees", -rotacao_alvo, 0.8)
		
# ==============================================================================
# 9. UTILITÁRIOS
# ==============================================================================

func get_game_manager() -> Node:
	var gm = get_node_or_null("GameManager")
	if not gm: gm = get_node_or_null("../GameManager")
	return gm

func tocar_som(som: AudioStream) -> void:
	if som_pecas:
		som_pecas.stream = som
		som_pecas.bus = "Efeitos"
		som_pecas.play()
	else:
		print("ERRO: O nó Som_pecas não foi encontrado!")
		
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
	
	jogo_finalizado = false # Destrava a tela para voltar a piscar amarelo
	
	var estado_anterior = historico_partida.pop_back()
	
	if modo_pve and not estado_anterior["brancas"] and not historico_partida.is_empty():
		estado_anterior = historico_partida.pop_back()
	
	tabuleiro = estado_anterior["tabuleiro"]
	brancas = estado_anterior["brancas"]
	rei_moveu = estado_anterior["rei_moveu"]
	torres_moveram = estado_anterior["torres_moveram"]
	ultimo_movimento = estado_anterior["ultimo_movimento"]

	situacao = false
	selecionar_peca = Vector2(-1, -1)
	movimento = []
	exibir()
	
	if not modo_pve:
			animar_rotacao_tabuleiro()
			
	for child in quadrados.get_children(): child.queue_free()
	if check_indicator: check_indicator.color = Color(0,0,0,0)

func _on_btn_desfazer_mov_pressed() -> void:
	desfazer_ultima_jogada()

# ==============================================================================
# 11. INTELIGÊNCIA ARTIFICIAL (VIA STOCKFISH / PYTHON EM SEGUNDO PLANO)
# ==============================================================================

var ia_thread: Thread

func iniciar_turno_ia() -> void:
	ia_pensando = true
	
	# A MÁGICA CONTRA O TRAVAMENTO: 
	# Limpamos a Thread antiga AQUI, antes de criar a nova, e não no final.
	if ia_thread and ia_thread.is_started():
		ia_thread.wait_to_finish()
	
	var fen_atual = matriz_para_fen()
	
	ia_thread = Thread.new()
	ia_thread.start(_chamar_python_em_background.bind(fen_atual, dificuldade_ia))

# Essa função roda "por debaixo dos panos" sem travar a tela
func _chamar_python_em_background(fen_atual: String, dificuldade: int) -> void:
	var caminho_script = ProjectSettings.globalize_path("res://scripts/chess_bridge.py") 
	var args = PackedStringArray([caminho_script, fen_atual, "get_ai_move", str(dificuldade)])
	var output_lines = []
	
	# Executa o Python e espera (como está numa Thread, o jogo não congela)
	var exit_code = OS.execute("python", args, output_lines, true)
	var melhor_jogada_uci = ""
	
	if exit_code == 0 and output_lines.size() > 0:
		var output_text = "".join(output_lines)
		var json = JSON.new()
		if json.parse(output_text.strip_edges()) == OK:
			var resposta = json.data
			if typeof(resposta) == TYPE_DICTIONARY and resposta.has("status") and resposta["status"] == "success":
				melhor_jogada_uci = resposta["move_uci"]
			else:
				print("Erro do Python: ", resposta.get("message", "Desconhecido"))
	else:
		print("Falha ao executar Python. Código: ", exit_code)
		
	# Manda a resposta de volta para o jogo principal (de forma segura)
	call_deferred("_finalizar_turno_ia", melhor_jogada_uci)

func _finalizar_turno_ia(jogada_uci: String) -> void:
	# 1. Dá a "baixa" na Thread liberando a memória do PC
	if ia_thread and ia_thread.is_started():
		ia_thread.wait_to_finish()
		
	# 2. Executa a jogada
	if jogada_uci != "":
		print("Stockfish jogou: ", jogada_uci)
		var coordenadas = uci_para_coordenadas(jogada_uci)
		executar_movimento_ia(coordenadas["origem"], coordenadas["destino"])
	else:
		print("A IA falhou em retornar uma jogada.")
		
	ia_pensando = false

# Essa função roda automaticamente sempre que o jogo/fase é fechado
func _exit_tree() -> void:
	if ia_thread and ia_thread.is_started():
		ia_thread.wait_to_finish()

func executar_movimento_ia(origem: Vector2, destino: Vector2) -> void:
	selecionar_peca = origem
	movimento = [destino]
	definir_movimento(int(destino.y), int(destino.x))

# --- TRADUTORES (GODOT <-> PYTHON) ---

func matriz_para_fen() -> String:
	var fen = ""
	for y in range(TAMANHO_TABULEIRO):
		var casas_vazias = 0
		for x in range(TAMANHO_TABULEIRO):
			var peca = tabuleiro[y][x]
			if peca == 0:
				casas_vazias += 1
			else:
				if casas_vazias > 0:
					fen += str(casas_vazias)
					casas_vazias = 0
				
				var letra = ""
				match abs(peca):
					1: letra = "P"
					2: letra = "N"
					3: letra = "B"
					4: letra = "R"
					5: letra = "Q"
					6: letra = "K"
				
				if peca < 0:
					letra = letra.to_lower()
					
				fen += letra
				
		if casas_vazias > 0:
			fen += str(casas_vazias)
			
		if y < 7:
			fen += "/" 
			
	var letra_turno = "w" if brancas else "b"
	fen += " " + letra_turno + " KQkq - 0 1"
	
	return fen

func uci_para_coordenadas(jogada_uci: String) -> Dictionary:
	var colunas = {"a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7}
	
	var origem_x = colunas[jogada_uci[0]]
	var origem_y = 8 - int(jogada_uci[1])
	
	var destino_x = colunas[jogada_uci[2]]
	var destino_y = 8 - int(jogada_uci[3])
	
	return {
		"origem": Vector2(origem_x, origem_y),
		"destino": Vector2(destino_x, destino_y)
	}
