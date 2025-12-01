extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const KNOCKBACK_FORCE = 200.0 # Força do empurrão ao tomar dano

# --- VARIÁVEIS ---
var health := 5
var is_attacking := false
var is_jumping := false
var knockback_vector := Vector2.ZERO # Vetor para controlar o empurrão

# Referências
@onready var animation := $anim as AnimatedSprite2D
@onready var attack_area_collision := $AttackArea/CollisionShape2D 

func _physics_process(delta: float) -> void:
	# 1. Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Se estiver sofrendo Knockback, sai da função
	if knockback_vector != Vector2.ZERO:
		velocity.x = knockback_vector.x
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, 500 * delta)
		move_and_slide()
		return

	# --- MUDANÇA PRINCIPAL AQUI ---
	# Verificamos o Input de ataque ANTES de verificar se está atacando ou andando.
	# Isso garante que a animação de ataque tenha prioridade absoluta no Frame 1.
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		start_attack()

	# 3. Se estiver atacando, trava o movimento e SAI DA FUNÇÃO IMEDIATAMENTE
	if is_attacking:
		velocity.x = 0 
		move_and_slide()
		return # O return aqui impede que o código abaixo (idle/run) rode

	# 4. CONTROLES DE MOVIMENTO (Só roda se não entrou no return acima)
	
	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Movimento Esquerda/Direita
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		# Vira o sprite e a área de ataque
		animation.scale.x = direction
		if direction > 0:
			$AttackArea.scale.x = 1
		else:
			$AttackArea.scale.x = -1
			
		if !is_jumping:
			animation.play("run")
	elif is_jumping:
		animation.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle")

	move_and_slide()

# --- SISTEMA DE ATAQUE ---
func start_attack():
	# Verifica se já está atacando para não reiniciar
	if is_attacking:
		return

	is_attacking = true
	animation.play("attack") 
	
	# Ativa a colisão da espada
	attack_area_collision.disabled = false
	
	# --- MUDANÇA AQUI ---
	# Em vez de esperar a animação, esperamos um tempo fixo.
	# 0.4 segundos é um bom valor médio. Aumente ou diminua conforme sua animação.
	await get_tree().create_timer(0.6).timeout 
	# --------------------
	
	# Desativa a colisão e libera o movimento
	attack_area_collision.disabled = true
	is_attacking = false
	animation.play("idle")

# --- SISTEMA DE RECEBER DANO (Chamado pelo inimigo) ---
func player_take_damage(enemy_position_x = 0):
	# Se já estiver tomando empurrão, ignora (invencibilidade temporária)
	if knockback_vector != Vector2.ZERO:
		return
		
	health -= 1
	print("DANO RECEBIDO! Vida restante: ", health)
	
	# --- EFEITO DE EMPURRÃO (KNOCKBACK) ---
	# Calcula a direção: se o inimigo está na direita, empurra pra esquerda
	var direction_push = -1
	if enemy_position_x < global_position.x:
		direction_push = 1 # Inimigo na esquerda, empurra pra direita
	
	knockback_vector = Vector2(direction_push * KNOCKBACK_FORCE, -150) # Empurra pro lado e um pouco pra cima
	
	# --- EFEITO VISUAL (PISCAR VERMELHO) ---
	animation.modulate = Color(1, 0, 0) # Vermelho
	await get_tree().create_timer(0.3).timeout
	animation.modulate = Color(1, 1, 1) # Normal
	
	if health <= 0:
		print("GAME OVER")
		get_tree().reload_current_scene()

# Sinal da espada acertando inimigo
func _on_attack_area_body_entered(body: Node2D) -> void:
	# ESSE PRINT VAI CONTAR O QUE A ESPADA TOCOU
	print("Espada acertou: ", body.name) 
	
	if body.is_in_group("enemies"):
		print("  -> É um inimigo! Causando dano...")
		if body.has_method("take_damage"):
			body.take_damage()
