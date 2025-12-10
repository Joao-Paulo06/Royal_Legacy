extends Node
# Este script controla a troca de telas do jogo (menus e tabuleiro).

# Referências para as telas da cena, obtidas automaticamente quando a cena carrega.
@onready var menu_principal = $cen_menu_principal
@onready var tela_novo_jogo = $cen_menu_novo_jogo
@onready var tela_opcoes = $cen_menu_opcoes
@onready var tabuleiro: Sprite2D = $tabuleiro

# Array que armazenará todas as telas para facilitar esconder/mostrar.
var telas: Array[Node] = []

func _ready() -> void:
	# Preenche o array com todas as telas que devem ser controladas
	telas = [menu_principal, tela_novo_jogo, tela_opcoes, tabuleiro]

	# Exibe inicialmente o menu principal
	mostrar_tela(menu_principal)
	
func mostrar_tela(tela: Node) -> void:
	# Esconde todas as telas existentes
	for t in telas:
		t.visible = false

	# Mostra somente a tela desejada
	tela.visible = true

##############################################
#     BOTÕES DO MENU PRINCIPAL (primeira tela)
##############################################

func _on_btn_novo_jogo_pressed() -> void:
	# Vai para o menu "Novo Jogo"
	mostrar_tela(tela_novo_jogo)
	
func _on_btn_opcoes_pressed() -> void:
	# Vai para o menu "Opções"
	mostrar_tela(tela_opcoes)

func _on_btn_sair_pressed() -> void:
	# Sai completamente do jogo
	get_tree().quit()

##############################################
#     BOTÕES DA TELA "NOVO JOGO"
##############################################

func _on_btn_retornar_de_novo_jogo_pressed() -> void:
	# Volta ao menu principal
	mostrar_tela(menu_principal)

func _on_btn_retornar_de_tabuleiro_pressed() -> void:
	# Volta ao menu novo jogo
	mostrar_tela(tela_novo_jogo)
	
func _on_btn_p_v_e_pressed() -> void:
	# Jogador vs IA → mostra o tabuleiro
	# (Aqui no futuro você vai iniciar IA, dificuldade, etc.)
	pass
	
func _on_btn_p_v_p_pressed() -> void:
	# Jogador vs Jogador local
	# (Ainda não implementado)
	mostrar_tela(tabuleiro)

func _on_btn_p_v_p_online_pressed() -> void:
	# Modo online
	# (Ainda não implementado)
	pass

##############################################
#     BOTÕES DA TELA "OPÇÕES"
##############################################

func _on_btn_retornar_de_opcoes_pressed() -> void:
	# Volta ao menu principal
	mostrar_tela(menu_principal)
	
func _on_btn_sons_pressed() -> void:
	# Aqui você vai configurar sons, volume, efeitos, etc.
	pass

func _on_btn_temas_pressed() -> void:
	# Aqui você trocará skins, cores, temas do jogo
	pass

func _on_btn_creditos_pressed() -> void:
	# Aqui você criará uma tela ou popup contendo créditos do jogo
	pass
