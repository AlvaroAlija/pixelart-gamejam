extends Control


func _ready():
	var musica = $AudioStreamPlayer2D
	musica.volume_db = -80  # volumen mínimo (silencio)
	musica.play()
	
	var tween = create_tween()
	tween.tween_property(musica, "volume_db", 0, 3.0)  # sube de -80 a 0 en 3 segundos



func _on_button_pressed() -> void:
	GameState.go_to_next_level()


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
