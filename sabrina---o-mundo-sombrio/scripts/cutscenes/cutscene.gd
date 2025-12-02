extends Node2D

var page = 1

func _ready():
	_atualizar_quadros()

func _input(event):
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		avancar_pagina()

# Pular a cutscene com a tecla P
	if event.is_action_pressed("skip_cutscene"):
		pular_cutscene()

func avancar_pagina():
	page += 1
	print("Nova página: ", page)
	_atualizar_quadros()

	if page > 16:
		get_tree().change_scene_to_file("res://levels/world_01.tscn")

func _on_seta_direita_pressed() -> void:
	avancar_pagina()

func _atualizar_quadros():
	for i in range(1, 17):
		var quadro = get_node("quadro%02d" % i)
		quadro.visible = (i == page)

func _on_btnPular_pressed():
	pular_cutscene()

func pular_cutscene():
	get_tree().change_scene_to_file("res://levels/world_01.tscn")
