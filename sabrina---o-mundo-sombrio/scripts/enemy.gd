extends CharacterBody2D
class_name InimigoBase

# --- CONFIGURAÇÕES (Editáveis no Inspector) ---
@export_category("Movimento")
@export var speed: float = 40.0 
@export var gravity_scale: float = 1.0

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
# Pega a gravidade padrão do projeto
var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Inicializa a vida com o valor máximo configurado
	current_health = max_health
	# Garante que a animação inicial está correta
	anim.play("walk")

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += default_gravity * gravity_scale * delta

	# Máquina de Estados: Decide o comportamento baseado no estado atual
	match current_state:
		State.WALK:
			_handle_movement()
		State.HURT:
			_handle_hurt_state()
		State.DEAD:
			velocity.x = 0 # Garante que não se move morto

	move_and_slide()

# Lógica de movimento separada para organização
func _handle_movement() -> void:
	# Verifica colisão com parede
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1

	# Vira a textura
	texture.flip_h = (direction == 1)
	
	# Aplica velocidade constante
	# NOTA: Removemos o 'delta' aqui pois 'velocity' já é pixels/segundo
	velocity.x = direction * speed

# Lógica enquanto está machucado (parado)
func _handle_hurt_state() -> void:
	velocity.x = 0

# --- SISTEMA DE DANO (Chamado pelo Player) ---
func take_damage() -> void:
	if current_state == State.DEAD:
		return # Não toma dano se já estiver morto

	current_health -= 1
	
	if current_health <= 0:
		change_state(State.DEAD)
	else:
		change_state(State.HURT)

# Função para gerenciar a troca de estados e animações
func change_state(new_state: State) -> void:
	current_state = new_state
	
	match current_state:
		State.WALK:
			anim.play("walk")
		State.HURT:
			anim.play("hurt")
		State.DEAD:
			anim.play("hurt") # Ou "dead" se tiver essa animação
			# Opcional: Desativar colisão aqui se necessário

# --- SINAIS ---
func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		if current_state == State.DEAD:
			queue_free() # Destrói o objeto
		else:
			# Se sobreviveu, volta a andar
			change_state(State.WALK)
