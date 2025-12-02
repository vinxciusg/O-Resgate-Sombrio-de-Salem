extends Control

signal time_over

# --- ATIVAÇÃO DO HUD ---
# Se esta cena não tiver HUD completo, defina hud_active = false
var hud_active := true

@onready var potions_counter: Label = $container/potions_container/potions_counter
@onready var timer_counter: Label = $container/timer_container/timer_counter
@onready var life_counter: Label = $container/life_container/life_counter
@onready var clock_timer: Timer = $clock_timer

var minutes = 0
var seconds = 0

@export_range(0,5) var default_minutes := 1
@export_range(0,59) var default_seconds := 0


func _ready():
	if hud_active:
		potions_counter.text = str("%04d" % Globals.potions)
		timer_counter.text = str("%02d" % default_minutes) + ":" + str("%02d" % default_seconds)
		reset_clock_timer()


func _process(delta):
	if hud_active:
		potions_counter.text = str("%04d" % Globals.potions)


func _on_clock_timer_timeout():
	if not hud_active:
		return

	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
	seconds -= 1
	
	timer_counter.text = "%02d:%02d" % [minutes, seconds]

	if minutes <= 0 and seconds <= 0:
		time_over.emit()


func reset_clock_timer():
	minutes = default_minutes
	seconds = default_seconds


func update_life(player_health):
	if hud_active and life_counter:
		life_counter.text = str(player_health)


func _on_player_life_changed(player_health: Variant):
	update_life(player_health)
