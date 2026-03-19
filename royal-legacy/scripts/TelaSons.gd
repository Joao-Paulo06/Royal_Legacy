extends Control

# Pegamos os IDs dos canais de áudio que criamos lá no Passo 1
var bus_master = AudioServer.get_bus_index("Master")
var bus_musica = AudioServer.get_bus_index("Musica")
var bus_efeitos = AudioServer.get_bus_index("Efeitos")

func _ready() -> void:
	# Ajusta os sliders para mostrarem o volume atual quando a tela abrir
	$marg_ctn_sons/pnl_ctn_sons/vert_ctn_sons/slider_vol_geral.value = db_to_linear(AudioServer.get_bus_volume_db(bus_master))
	$marg_ctn_sons/pnl_ctn_sons/vert_ctn_sons/slider_musica.value = db_to_linear(AudioServer.get_bus_volume_db(bus_musica))
	$marg_ctn_sons/pnl_ctn_sons/vert_ctn_sons/slider_efeitos.value = db_to_linear(AudioServer.get_bus_volume_db(bus_efeitos))

# --- SLIDERS ---

func _on_slider_geral_value_changed(value: float) -> void:
	# linear_to_db converte a porcentagem do slider (0.0 a 1.0) para os Decibéis da Godot
	AudioServer.set_bus_volume_db(bus_master, linear_to_db(value))

func _on_slider_musica_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_musica, linear_to_db(value))

func _on_slider_efeitos_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_efeitos, linear_to_db(value))
