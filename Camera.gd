extends Camera

signal user_input(data)

var _mouse_position: Vector2


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _mouse_position = event.position


func _physics_process(_delta: float) -> void:
    if Input.is_action_pressed("move"):
        var space_state = get_world().direct_space_state
        var from = project_ray_origin(_mouse_position)
        var to = from + project_ray_normal(_mouse_position) * 1000
        var result = space_state.intersect_ray(from, to)
        if result:
            var new_pos = Vector3(result.position.x, 1, result.position.z)
            emit_signal("user_input", {"action": "move", "position": new_pos})
