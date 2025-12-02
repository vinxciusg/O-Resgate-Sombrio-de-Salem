extends Area2D

@onready var transition = get_parent().get_node("transition")
@export var victory_screen : String = ""

func _on_body_entered(body: Node2D):
	if body.name == "player" and !victory_screen == "":
		transition.change_scene(victory_screen)
	else:
		print("No Scene Loaded")
