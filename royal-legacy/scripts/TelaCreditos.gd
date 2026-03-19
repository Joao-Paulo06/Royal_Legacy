extends ScrollContainer

@export var text_node : RichTextLabel
@export_range(1, 100000, 0.1) var credits_time : float = 40.0
@export_range(0, 100000, 0.1) var margin_increment : float = 0

@onready var margin: MarginContainer = $marg_ctn_creditos

# Criamos uma variável para guardar a animação, assim podemos pará-la se o jogador sair da tela
var tween: Tween

func _ready() -> void:
	# Aqui a gente diz para a Godot avisar sempre que a tela aparecer ou sumir
	visibility_changed.connect(_ao_mudar_visibilidade)

func _ao_mudar_visibilidade() -> void:
	if visible:
		comecar_creditos()
	else:
		# Se a tela for escondida (jogador clicou em Voltar), a gente "mata" a animação
		if tween:
			tween.kill()

func comecar_creditos() -> void:
	# Zera a barra de rolagem para o texto sempre começar lá debaixo!
	scroll_vertical = 0
	
	await get_tree().process_frame
	
	tween = create_tween() 
	
	var text_box_size = text_node.size.y
	var window_size = get_viewport_rect().size.y
	
	margin.add_theme_constant_override("margin_top", window_size + margin_increment)
	margin.add_theme_constant_override("margin_bottom", window_size + margin_increment)

	var scroll_amount : int = ceil(text_box_size + window_size + margin_increment)

	tween.tween_property(
		self,
		"scroll_vertical",
		scroll_amount,
		credits_time
	)
	
	tween.finished.connect(_acabou)

func _acabou() -> void:
	# Pega o nó pai (o seu Estruturador)
	var estruturador = get_parent()
	
	# Verifica se o pai é realmente o Estruturador e manda ele mostrar o Menu Principal
	if estruturador and estruturador.has_method("mostrar_tela"):
		estruturador.mostrar_tela(estruturador.menu_principal)
		
		# Opcional: Zera a rolagem para a próxima vez que o jogador abrir os créditos
		scroll_vertical = 0
