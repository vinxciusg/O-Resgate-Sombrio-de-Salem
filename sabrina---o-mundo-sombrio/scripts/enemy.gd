extends CharacterBody2D
class_name InimigoBase

# --- CONFIGURAÇÕES (Editáveis no Inspector) ---
@export_category("Movimento")
@export var speed: float = 40.0 # Ajuste se estiver rápido/lento
@export var gravity_scale: float = 1.0
@export var patrol_distance: float = 40.0 # Distância máxima em pixels para patrulha

@export_category("Combate")
@export var max_health: int = 3
@export var damage_amount: int = 1

# --- REFERÊNCIAS INTERNAS ---
@onready var wall_detector: RayCast2D = $wall_detector
@onready var texture: Sprite2D = $texture
@onready var anim: AnimationPlayer = $anim

# --- ESTADOS DO INIMIGO ---
enum State { WALK, HURT, DEAD }
var current_state: State = State.WALK

# --- VARIÁVEIS DE CONTROLE ---
var current_health: int
var direction: int = -1
var start_position_x: float # Memoriza a posição inicial X
var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Inicializa a vida
	current_health = max_health
	
	# Salva a posição onde o inimigo nasceu para calcular a distância
	start_position_x = global_position.x
	
	# Garante animação inicial
	anim.play("walk")

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += default_gravity * gravity_scale * delta

	# Máquina de Estados
	match current_state:
		State.WALK:
			_handle_movement()
		State.HURT:
			_handle_hurt_state()
		State.DEAD:
			velocity.x = 0

	move_and_slide()

# --- LÓGICA DE MOVIMENTO (Atualizada com Limite de Distância) ---
func _handle_movement() -> void:
	# 1. Verifica colisão com parede
	var hit_wall = wall_detector.is_colliding()
	
	# 2. Verifica se andou demais para a ESQUERDA
	# (Posição atual < Posição Inicial - Distância)
	var too_far_left = (global_position.x < start_position_x - patrol_distance) and direction == -1
	
	# 3. Verifica se andou demais para a DIREITA
	# (Posição atual > Posição Inicial + Distância)
	var too_far_right = (global_position.x > start_position_x + patrol_distance) and direction == 1

	# Se qualquer uma das condições for verdadeira, vira o inimigo
	if hit_wall or too_far_left or too_far_right:
		_flip_direction()
	
	# Aplica a velocidade
	velocity.x = direction * speed

# Função auxiliar para virar o inimigo e seus sensores
func _flip_direction() -> void:
	direction *= -1
	wall_detector.scale.x *= -1
	texture.flip_h = (direction == 1)

# Lógica enquanto está machucado (parado)
func _handle_hurt_state() -> void:
	velocity.x = 0

# --- SISTEMA DE DANO ---
func take_damage() -> void:
	if current_state == State.DEAD:
		return

	current_health -= 1
	
	if current_health <= 0:
		change_state(State.DEAD)
	else:
		change_state(State.HURT)

# Gerenciador de Estados
func change_state(new_state: State) -> void:
	current_state = new_state
	
	match current_state:
		State.WALK:
			anim.play("walk")
		State.HURT:
			anim.play("hurt")
		State.DEAD:
			anim.play("hurt") # Ou "dead"

# --- SINAIS ---
func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		if current_state == State.DEAD:
			queue_free()
		else:
			change_state(State.WALK)
