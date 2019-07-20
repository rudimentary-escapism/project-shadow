extends Camera

signal user_input(msg)

enum { NOTHING, MOVE, OBSTACLE, ALLY, ENEMY }

var mouse_position: Vector2
var ray: Dictionary


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        mouse_position = event.position
            

func _physics_process(_delta: float) -> void:
    var space_state: = get_world().direct_space_state
    var from: = project_ray_origin(mouse_position)
    var to: = from + project_ray_normal(mouse_position) * 1000
    ray = space_state.intersect_ray(from, to)
            

func _process(_delta: float) -> void:
    set_mouse_cursor(ray)
    if Input.is_action_just_pressed("action"):
        match type(ray):
            MOVE:
                var new_pos = Vector3(ray.position.x, 1, ray.position.z)
                emit_signal("user_input", { "move": new_pos })
            ENEMY:
                emit_signal("user_input",
                    { "attack": ray.collider.get_node("../..") })
        
        
func set_mouse_cursor(ray: Dictionary) -> void:
    match type(ray):
        MOVE:
            Events.emit_signal("mouse_targeted", "move")
        OBSTACLE:
            Events.emit_signal("mouse_targeted", "obstacle")
        ALLY:
            Events.emit_signal("mouse_targeted", "ally")
        ENEMY:
            Events.emit_signal("mouse_targeted", "enemy")
        NOTHING:
            Events.emit_signal("mouse_targeted", "nothing")


func type(ray: Dictionary) -> int:
    if not ray:
        return NOTHING
    
    var collider = ray.collider
    if collider is GridMap:
        if collider.can_unit_get(ray.position):
            return MOVE
        return OBSTACLE
        
    var unit = collider.get_node("../..")
    if unit is Pawn:
        if unit.team == "Ally":
            return ALLY
        return ENEMY
    
    return NOTHING
