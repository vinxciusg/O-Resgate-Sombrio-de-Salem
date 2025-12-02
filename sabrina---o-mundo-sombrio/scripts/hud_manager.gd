extends Control

signal time_over

@onready var potions_counter: Label = $container/potions_container/potions_counter as Label
@onready var timer_counter: Label = $container/timer_container/timer_counter as Label
@onready var life_counter: Label = $container/life_container/life_counter as Label
@onready var clock_timer: Timer = $clock_timer as Timer

var minutes = 0
var seconds = 0
@export_range(0,5) var default_minutes := 1
@export_range(0,59) var default_seconds := 0


func _ready():
	potions_counter.text = str("%04d" % Globals.potions)
	timer_counter.text = str("%02d" % default_minutes) + ":" + str("%02d" % default_seconds)
	reset_clock_timer()

func _process(delta):
	potions_counter.text = str("%04d" % Globals.potions)

func _on_clock_timer_timeout():
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
	seconds -= 1
	
	timer_counter.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)
	
	if minutes <= 0 and seconds <= 0:
		time_over.emit()
	
func reset_clock_timer():
	minutes = default_minutes
	seconds = default_seconds

# Sua função original (mantivemos ela)
func update_life(player_health):	
	if life_counter:
		life_counter.text = "" + str(player_health) # Adicionei o "x " para ficar bonito
	else:
		print("ERRO: O life_counter não existe!")

# --- A CORREÇÃO ESTÁ AQUI EMBAIXO ---
# O sinal está chamando esta função agora. 
# Nós simplesmente mandamos ela chamar a de cima.
func _on_player_life_changed(player_health: Variant) -> void:
	update_life(player_health)
