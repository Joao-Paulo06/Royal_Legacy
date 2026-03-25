extends TextureRect

@onready var opt_btn_temas: OptionButton = $marg_ctn_temas/pnl_ctn_temas/vert_ctn_temas/opt_btn_temas

func _ready() -> void:
	# Quando o menu abrir, força o botão a mostrar o tema que já estava salvo no Global
	if Global.get("tema_escolhido") != null:
		opt_btn_temas.selected = Global.tema_escolhido

func _on_opt_btn_temas_item_selected(index: int) -> void:
	# Salva a escolha do jogador no nosso script Global!
	Global.tema_escolhido = index
	print("Tema escolhido: ", Global.tema_escolhido)
	
	# Avisa qualquer nó do grupo "tabuleiro" que o tema mudou
	get_tree().call_group("tabuleiro", "atualizar_tema", index)
