extends CharacterBody2D

# SINAL PARA O HUD (Avisa que a vida mudou)
signal life_changed(player_health)

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

func _ready():
	# Avisa o HUD o valor inicial da vida assim que o jogo começa
	life_changed.emit(health)

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

	# 3. Input de Ataque (Prioridade)
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		start_attack()

	# 4. Se estiver atacando, trava o movimento
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# 5. Controles de Movimento
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
	if is_attacking:
		return

	is_attacking = true
	animation.play("attack")
	
	# Ativa a colisão da espada
	attack_area_collision.disabled = false
	
	# Tempo da animação (Ajuste conforme necessário)
	await get_tree().create_timer(0.6).timeout
	
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
	
	# --- ATUALIZAÇÃO DO HUD ---
	# Avisa o HUD que a vida mudou
	life_changed.emit(health)
	# --------------------------
		
	# --- EFEITO DE EMPURRÃO (KNOCKBACK) ---
	var direction_push = -1
	if enemy_position_x < global_position.x:
		direction_push = 1 # Inimigo na esquerda, empurra pra direita
	
	knockback_vector = Vector2(direction_push * KNOCKBACK_FORCE, -150)
	
	# --- EFEITO VISUAL (PISCAR VERMELHO) ---
	animation.modulate = Color(1, 0, 0) # Vermelho
	await get_tree().create_timer(0.3).timeout
	animation.modulate = Color(1, 1, 1) # Normal
	
	if health <= 0:
		get_tree().reload_current_scene()

# Sinal da espada acertando inimigo
func _on_attack_area_body_entered(body: Node2D) -> void:	
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage()


func _on_life_changed(player_health: Variant) -> void:
	pass # Replace with function body.
