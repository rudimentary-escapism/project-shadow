extends Spatial
class_name Pawn

onready var grid: GridMap = get_parent()
onready var tween: Tween = $Tween

export (int) var max_steps := 2
export (bool) var is_playable = false

enum { IDLE, TURN, MOVE }

var _remain_steps := 0
var status = IDLE


func start_turn():
    set_steps(_remain_steps + max_steps)
    status = TURN
    

func end_turn():
    status = IDLE
    

func user_input(data):
    if not is_playable or status != TURN:
        return

    match data.action:
        "move":
            status = MOVE
            move_to(data.position)


func _ready() -> void:
    translation = grid.world_to_world(translation)
                    

func set_steps(steps: int) -> void:
    _remain_steps = steps
    $Camera/Label.text = str(_remain_steps)
    
func move_to(target_position: Vector3) -> void:
    var path = grid.find_path(translation, target_position)
    if len(path) == 0:
        status = TURN
        return
    path.pop_front()
    for point in path:
        if _remain_steps == 0:
            break
        step(point) 
        set_steps(_remain_steps - 1)
        yield(tween, "tween_completed")
    status = TURN


func step(point: Vector3) -> void:
    if tween.interpolate_property(self, "translation", translation,
        point, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT):
        if tween.start():
            return
    translation = point  
