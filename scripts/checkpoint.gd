extends Area2D

@export var is_active = false

func _on_body_entered(body: Node2D) -> void:
		if body.is_in_group("player"):
			body.set_checkpoint(global_position)
			is_active = true
