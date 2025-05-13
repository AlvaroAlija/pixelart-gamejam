extends Control




func _on_button_pressed() -> void:
	GameState.go_to_next_level()


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
