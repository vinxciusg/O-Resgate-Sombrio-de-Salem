extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = -400.0

# Variáveis novas para combate
var health := 3 # Quantidade de vida do inimigo
var is_hurt := false # Variável para travar o movimento quando tomar dano

@onready var wall_detector := $wall_detector as RayCast2D
@onready var texture := $texture as Sprite2D
@onready var anim := $anim # Certifique-se que o nó de animação se chama "anim"

var direction := -1
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# --- NOVO: Se estiver machucado, para o movimento e sai da função ---
	if is_hurt:
		velocity.x = 0
		move_and_slide()
		return 
	# --------------------------------------------------------------------

	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
	
	if direction == 1:
		texture.flip_h = true
	else:
		texture.flip_h = false
	
	# Seu cálculo de movimento original
	velocity.x = direction * SPEED * delta

	move_and_slide()

# --- NOVA FUNÇÃO: Chamada pelo Player quando atacar ---
func take_damage():
	health -= 1
	is_hurt = true # Impede que ele ande enquanto sofre dano
	
	if health <= 0:
		# Se a vida zerou, toca animação de morte ou machucado final
		# Se você tiver uma animação chamada "dead", troque abaixo
		anim.play("hurt") 
	else:
		# Se ainda tem vida, toca animação de machucado
		anim.play("hurt")
# -----------------------------------------------------

# --- ATUALIZADO: O que fazer quando a animação termina ---
func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		if health <= 0:
			# Se a vida acabou, destrói o inimigo
			queue_free()
		else:
			# Se ainda tem vida, volta a andar
			is_hurt = false
			# IMPORTANTE: Coloque aqui o nome da sua animação de andar/correr
			# Exemplo: anim.play("walk") ou anim.play("run")
			anim.play("walk")
			
			
