extends Control

func _ready():
	# garante que o jogo NÃO está pausado quando essa cena abre
	get_tree().paused = false
	
	# (opcional, mas ajuda) garantir que esse Control capture o clique
	mouse_filter = MOUSE_FILTER_STOP

func _on_restart_btn_pressed():
	get_tree().change_scene_to_file("res://prefabs/tittle_screen.tscn")

func _on_quit_btn_pressed():
	get_tree().quit()
