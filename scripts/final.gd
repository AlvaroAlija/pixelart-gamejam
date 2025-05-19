extends Node2D


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/end_menu.tscn")
