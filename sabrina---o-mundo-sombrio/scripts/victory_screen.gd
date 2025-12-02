extends Control

func _ready():
	visible = true   # garante que aparece quando a cena carrega
	get_tree().paused = false  # caso venha de uma fase pausada (ex: gameover)
