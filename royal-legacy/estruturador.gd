extends Node

@onready var menu_principal = $cen_menu_principal
@onready var tela_novo_jogo = $cen_menu_novo_jogo
@onready var tela_opcoes = $cen_menu_opcoes

var telas: Array[Node] = []

func _ready() -> void:
	telas = [menu_principal, tela_novo_jogo, tela_opcoes]
	mostrar_tela(menu_principal)
	
func mostrar_tela(tela: Node) -> void:
	for t in telas:
		t.visible = false
	tela.visible = true

#Botões da tela de menu principal.
func _on_btn_novo_jogo_pressed() -> void:
	mostrar_tela(tela_novo_jogo)
	
func _on_btn_opcoes_pressed() -> void:		
	mostrar_tela(tela_opcoes)

func _on_btn_sair_pressed() -> void:
	get_tree().quit()

#Botões da tela de novo jogo.
func _on_btn_retornar_de_novo_jogo_pressed() -> void:
	mostrar_tela(menu_principal)

func _on_btn_p_v_e_pressed() -> void:
	pass # Replace with function body.

func _on_btn_p_v_p_pressed() -> void:
	pass # Replace with function body.

func _on_btn_p_v_p_online_pressed() -> void:
	pass # Replace with function body.

#Botões da tela de opções.
func _on_btn_retornar_de_opcoes_pressed() -> void:
	mostrar_tela(menu_principal)
	
func _on_btn_sons_pressed() -> void:
	pass # Replace with function body.

func _on_btn_temas_pressed() -> void:
	pass # Replace with function body.

func _on_btn_creditos_pressed() -> void:
	pass # Replace with function body.
