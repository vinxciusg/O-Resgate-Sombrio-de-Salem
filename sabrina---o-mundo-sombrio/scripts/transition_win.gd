extends CanvasLayer

@onready var color_rect_win: ColorRect = $color_rect_win


func change_scene(path, delay = 1.5):
	var scene_transition = get_tree().create_tween()
	scene_transition.tween_property(color_rect_win, "threshold", 1.0, 0.5)
	await scene_transition.finished
	assert(get_tree().change_scene_to_file(path) == OK)
