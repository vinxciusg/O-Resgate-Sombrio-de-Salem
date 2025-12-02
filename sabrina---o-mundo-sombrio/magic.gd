extends Area2D

const SPEED = 400.0
var direction = 1 # 1 para direita, -1 para esquerda

func _process(delta):
	# Move a magia na direção certa
	position.x += SPEED * direction * delta

# Quando bater em algo
func _on_body_entered(body):
	# Se bater no inimigo
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage()
		queue_free() # Destrói a magia
		
	# Se bater na parede (TileMap ou chao)
	# (Verifique se o seu chao tem um nome ou layer especifica, aqui é um exemplo generico)
	elif body.name != "Player": 
		queue_free() # Destrói a magia ao bater na parede

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Destrói se sair da tela (para não pesar o jogo)
