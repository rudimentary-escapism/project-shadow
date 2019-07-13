extends Camera

signal user_input(data)

onready var mouse_target = $Interface/DevPanel/Mouse/Target

enum {MOVE, OBSTACLE, ALLY, ENEMY}

var _mouse_position: Vector2
var _ray: Dictionary


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _mouse_position = event.position
            

func _physics_process(_delta: float) -> void:
    var space_state = get_world().direct_space_state
    var from = project_ray_origin(_mouse_position)
    var to = from + project_ray_normal(_mouse_position) * 1000
    _ray = space_state.intersect_ray(from, to)
            

func _process(_delta: float):
    set_mouse_cursor()
    if Input.is_action_just_pressed("action") and _ray:
        match type(_ray.collider):
            MOVE:
                var new_pos = Vector3(_ray.position.x, 1, _ray.position.z)
                emit_signal("user_input",
                    {"action": "move", "position": new_pos})
            ENEMY:
                emit_signal("user_input",
                    {"action": "attack", "pawn": _ray.collider.find_parent("Unit*")})
        
        
func set_mouse_cursor() -> void:
    if not _ray:
        mouse_target.text = "nothing"
        return
    
    match type(_ray.collider):
        MOVE:
            mouse_target.text = "move"
        OBSTACLE:
            mouse_target.text = "obstacle"
        ALLY:
            mouse_target.text = "ally"
        ENEMY:
            mouse_target.text = "enemy"


func type(collider: Spatial) -> int:
    if collider is GridMap:
        if collider.can_unit_get(_ray.position):
            return MOVE
        return OBSTACLE
        
    var unit = collider.find_parent("Unit*")
    if unit is Pawn:
        if unit.is_playable:
            return ALLY
    return ENEMY
