extends Node
# Script de Gerenciamento de Telas (Estruturador)

# Referências para as telas (Verifique se os nomes batem com sua cena!)
@onready var menu_principal = $cen_menu_principal
@onready var tela_novo_jogo = $cen_menu_novo_jogo
@onready var tela_opcoes = $cen_menu_opcoes
@onready var tela_p_v_e: TextureRect = $cen_PvE # Tela de Dificuldade
@onready var tabuleiro: Sprite2D = $tabuleiro

var telas: Array[Node] = []

func _ready() -> void:
	# Lista todas as telas para facilitar a troca
	telas = [menu_principal, tela_novo_jogo, tela_opcoes, tabuleiro, tela_p_v_e]
	mostrar_tela(menu_principal)
	
func mostrar_tela(tela: Node) -> void:
	# Esconde todas
	for t in telas:
		if t: t.visible = false
	# Mostra só a escolhida
	if tela: tela.visible = true

# ==============================================================================
# BOTÕES - MENU PRINCIPAL
# ==============================================================================

func _on_btn_novo_jogo_pressed() -> void:
	mostrar_tela(tela_novo_jogo)
	
func _on_btn_opcoes_pressed() -> void:
	mostrar_tela(tela_opcoes)

func _on_btn_sair_pressed() -> void:
	get_tree().quit()

# ==============================================================================
# BOTÕES - NOVO JOGO (SELEÇÃO DE MODO)
# ==============================================================================

func _on_btn_retornar_de_novo_jogo_pressed() -> void:
	mostrar_tela(menu_principal)

func _on_btn_retornar_de_tabuleiro_pressed() -> void:
	# Reinicia o jogo completamente (Hard Reset)
	get_tree().change_scene_to_file("res://cenas/estruturador.tscn")

func _on_btn_p_v_e_pressed() -> void:
	# Vai para a tela de escolher dificuldade
	mostrar_tela(tela_p_v_e)
	
func _on_btn_p_v_p_pressed() -> void:
	# CORREÇÃO IMPORTANTE: Desliga a IA para jogar de 2 jogadores
	Global.modo_pve = false 
	iniciar_partida()

func _on_btn_p_v_p_online_pressed() -> void:
	pass # Futuro: Online

# ==============================================================================
# BOTÕES - OPÇÕES
# ==============================================================================

func _on_btn_retornar_de_opcoes_pressed() -> void:
	mostrar_tela(menu_principal)
	
func _on_btn_sons_pressed() -> void:
	pass

func _on_btn_temas_pressed() -> void:
	pass

func _on_btn_creditos_pressed() -> void:
	pass

# ==============================================================================
# BOTÕES - TELA DE DIFICULDADE (PvE)
# ==============================================================================

func _on_btn_retornar_de_pve_pressed() -> void:
	mostrar_tela(tela_novo_jogo)

# --- Botões de Nível (Conecte o sinal 'pressed' de cada um) ---

func _on_btn_facil_pressed() -> void:
	Global.modo_pve = true
	Global.dificuldade_escolhida = 1
	iniciar_partida()

func _on_btn_mediano_pressed() -> void:
	Global.modo_pve = true
	Global.dificuldade_escolhida = 2
	iniciar_partida()

func _on_btn_dificil_pressed() -> void:
	Global.modo_pve = true
	Global.dificuldade_escolhida = 3
	iniciar_partida()

# ==============================================================================
# AUXILIARES
# ==============================================================================

func iniciar_partida() -> void:
	mostrar_tela(tabuleiro)
	# Força o tabuleiro a ler as novas configurações do Global
	tabuleiro._ready()
