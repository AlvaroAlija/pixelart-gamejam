extends Node

# Este es el índice del nivel actual
var current_level := 0

# Lista de rutas a los niveles en orden
var level_paths := [
	"res://menus/main_menu.tscn",
	"res://levels/cinematica.tscn",
	"res://levels/level_1.tscn",
	"res://levels/level_2.tscn",
	"res://levels/level_3.tscn",
	"res://levels/level_4.tscn",
	"res://levels/level_5.tscn",
	"res://levels/level_6.tscn",
	"res://levels/level_7.tscn",
	"res://levels/level_8.tscn",
	"res://levels/final.tscn"
	# Agrega más niveles aquí
]

func get_current_level_path() -> String:
	return level_paths[current_level]

func go_to_next_level():
	current_level += 1
	print("Siguiente nivel:", current_level)
	if current_level < level_paths.size():
		get_tree().change_scene_to_file(level_paths[current_level])
	else:
		get_tree().change_scene_to_file("res://menu.tscn")
		# Aquí puedes mandar al menú final, créditos, etc.
