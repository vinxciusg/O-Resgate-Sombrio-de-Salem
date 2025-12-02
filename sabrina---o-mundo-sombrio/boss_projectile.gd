extends Area2D

var speed = 300
var direction = -1 

# --- CONTROLE DE DISTÂNCIA ---
# Ajuste este valor para o tiro ir mais longe ou mais perto.
# Exemplo: 1.0 (perto), 2.0 (médio), 5.0 (longe/tela toda)
var lifetime := 1.5 
# -----------------------------

func _ready():
	# Inicia o cronômetro da morte
	# Assim que esse tempo acabar, o tiro se destrói sozinho
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position.x += speed * direction * delta

func _on_body_entered(body):
	# Lógica de Colisão (mantive a mesma que já funcionava)
	print("PROJÉTIL TOCOU EM: ", body.name)
	
	if body.is_in_group("player"):
		if body.has_method("player_take_damage"):
			body.player_take_damage(global_position.x)
		queue_free() # Destrói ao acertar
		
	# Ignora o Boss e Inimigos, destrói se bater na parede
	elif body.name != "BossLucifer" and not body.is_in_group("enemies"):
		queue_free() 

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
