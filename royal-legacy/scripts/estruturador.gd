extends Node
# Script de Gerenciamento de Telas

@onready var menu_principal = $cen_menu_principal
@onready var tela_novo_jogo = $cen_menu_novo_jogo
@onready var tela_opcoes = $cen_menu_opcoes
@onready var tabuleiro: Sprite2D = $tabuleiro

var telas: Array[Node] = []

func _ready() -> void:
	telas = [menu_principal, tela_novo_jogo, tela_opcoes, tabuleiro]
	mostrar_tela(menu_principal)
	
func mostrar_tela(tela: Node) -> void:
	for t in telas:
		t.visible = false
	tela.visible = true

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
# BOTÕES - NOVO JOGO
# ==============================================================================

func _on_btn_retornar_de_novo_jogo_pressed() -> void:
	mostrar_tela(menu_principal)

func _on_btn_retornar_de_tabuleiro_pressed() -> void:
	# Reinicia o jogo completamente
	get_tree().change_scene_to_file("res://cenas/estruturador.tscn") 

func _on_btn_p_v_e_pressed() -> void:
	pass # Futuro: Jogador vs IA
	
func _on_btn_p_v_p_pressed() -> void:
	mostrar_tela(tabuleiro) # Jogador vs Jogador

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
