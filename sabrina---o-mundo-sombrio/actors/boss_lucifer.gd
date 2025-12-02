extends CharacterBody2D

const BOSS_PROJECTILE = preload("res://prefabs/boss_projectile.tscn")
@export var max_health := 12

var current_health: int
var player_ref = null
var is_dying := false

@onready var anim = $anim
@onready var muzzle = $Muzzle
@onready var attack_timer = $AttackTimer

func _ready():
	current_health = max_health
	player_ref = get_tree().get_first_node_in_group("player")
	anim.play("idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player_ref and not is_dying:
		if player_ref.global_position.x < global_position.x:
			scale.x = 1 
		else:
			scale.x = -1 

	move_and_slide()

# --- SISTEMA DE COMBATE DINÂMICO ---
func _on_attack_timer_timeout():
	if is_dying: return
	
	# 1. Para o timer para não encavalar ataques
	attack_timer.stop()
	
	# 2. Escolhe o padrão de ataque (50% chance cada)
	var roll = randi() % 2
	
	if roll == 0:
		# Padrão A: Tiro Único (Rápido)
		await cast_spell()
	else:
		# Padrão B: Rajada de 3 Tiros (Intenso)
		await shoot_burst()
		
	# 3. Reinicia o timer para o próximo ciclo (se não morreu)
	if not is_dying:
		attack_timer.start()

# Função para atirar 3 vezes seguidas
func shoot_burst():
	for i in range(3):
		if is_dying: break # Para se morrer no meio
		await cast_spell()
		# Pequeno intervalo entre os tiros da rajada (ajuste aqui)
		await get_tree().create_timer(0.5).timeout

# Função de atirar (Sempre baixo agora)
func cast_spell():
	anim.play("attack")
	
	# Sincronia com o braço
	await get_tree().create_timer(0.8).timeout
	
	if is_dying: return
	
	var spell = BOSS_PROJECTILE.instantiate()
	spell.global_position = muzzle.global_position
	
	# Define direção
	if scale.x > 0: 
		spell.direction = -1
	else:
		spell.direction = 1
		
	# Sempre posiciona o tiro mais baixo (perto do chão)
	spell.position.y += 20 
		
	get_parent().add_child(spell)
	
	# Espera a animação terminar antes de liberar o próximo passo
	await anim.animation_finished
	
	if not is_dying:
		anim.play("idle")

# --- DANO E MORTE ---
func take_damage():
	if is_dying: return

	current_health -= 1
	print("Boss vida: ", current_health)
	
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
	
	if current_health <= 0:
		die()

func die():
	is_dying = true
	attack_timer.stop()
	
	modulate = Color(1, 0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.5)
	
	await tween.finished
	queue_free()
