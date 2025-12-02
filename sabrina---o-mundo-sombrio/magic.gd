extends Area2D

const SPEED = 400.0
var direction = 1

# --- CONTROLE DE DISTÂNCIA ---
# Mude este valor para aumentar ou diminuir a distância.
# 0.5 = Curto alcance
# 1.0 = Médio alcance
# 3.0 = Longo alcance
var tempo_de_vida := 0.5

func _ready():
	await get_tree().create_timer(tempo_de_vida).timeout
	queue_free()

func _process(delta):
	position.x += SPEED * direction * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage()
		queue_free() 
		
	elif body.name != "Player": 
		queue_free()
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
