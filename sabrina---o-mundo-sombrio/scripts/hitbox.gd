extends Area2D

func _on_body_entered(body):
	# Verifica se quem entrou foi o Player
	if body.name == "player": 
		# Verifica se o script do player tem a função de tomar dano
		if body.has_method("player_take_damage"):
			# Manda o Player tomar dano e avisa a posição do inimigo (owner) para o empurrão
			body.player_take_damage(owner.global_position.x)
