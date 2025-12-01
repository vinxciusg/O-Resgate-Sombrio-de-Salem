extends Area2D

var potions := 1
@onready var coin_3_sfx: AudioStreamPlayer = $coin3_sfx as AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass


func _on_body_entered(body: Node2D):
	$anim.play("collect")
	coin_3_sfx.play()
	#Evita a colisão dupla de poções
	await $collision.call_deferred("queue_free")
	Globals.potions += potions
	print(Globals.potions)

func _on_anim_animation_finished():
	queue_free()
