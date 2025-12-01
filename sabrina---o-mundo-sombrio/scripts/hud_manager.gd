extends Control

@onready var potions_counter: Label = $container/potions_container/potions_counter as Label
@onready var timer_counter: Label = $container/timer_container/timer_counter as Label
@onready var life_counter: Label = $container/life_container/life_counter as Label
@onready var clock_timer: Timer = $clock_timer as Timer

var minutes = 0
var seconds = 0
@export_range(0,5) var default_minutes := 1
@export_range(0,59) var default_seconds := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	potions_counter.text = str("%04d" % Globals.potions)
	timer_counter.text = str("%02d" % default_minutes) + ":" + str("%02d" % default_seconds)
	reset_clock_timer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	potions_counter.text = str("%04d" % Globals.potions)


func _on_clock_timer_timeout():
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
	seconds -= 1
	
	timer_counter.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)
	
func reset_clock_timer():
	minutes = default_minutes
	seconds = default_seconds
