extends Spatial
class_name Pawn

signal changed_steps(steps)

onready var grid: GridMap = get_parent()
onready var tween: Tween = $Tween

export (int) var hp := 2
export (int) var max_steps := 2
export (bool) var is_playable = false

enum { IDLE, TURN, ACTION }

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
            status = ACTION
            move_to(data.position)
        "attack":
            status = ACTION
            attack(data.pawn)


func _ready() -> void:
    translation = grid.world_to_world(translation)
                    

func set_steps(steps: int) -> void:
    _remain_steps = steps
    emit_signal("changed_steps", _remain_steps)
    
func move_to(target_position: Vector3) -> void:
    grid.remove_unit_from_map(grid.world_to_map(translation))
    var path = grid.find_path(translation, target_position)
    if len(path) == 0:
        grid.add_unit_to_map(grid.world_to_map(translation))
        status = TURN
        return
    path.pop_front()
    yield(move(path), "completed")
    grid.add_unit_to_map(grid.world_to_map(translation))
    status = TURN
    
    
func move(path: Array) -> void:
    for point in path:
        if _remain_steps == 0:
            break
        step(point)
        yield(tween, "tween_completed")
        set_steps(_remain_steps - 1)


func step(point: Vector3) -> void:
    if tween.interpolate_property(self, "translation", translation,
        point, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT):
        if tween.start():
            return
    translation = point


func attack(pawn: Pawn) -> void:
    grid.remove_unit_from_map(grid.world_to_map(translation))
    grid.remove_unit_from_map(grid.world_to_map(pawn.translation))
    var path = grid.find_path(translation, pawn.translation)
    if len(path) != 2:
        path.pop_front()
        path.pop_back()
        yield(move(path), "completed")
    grid.add_unit_to_map(grid.world_to_map(translation))
    grid.add_unit_to_map(grid.world_to_map(pawn.translation))
    pawn.damage(1)
    status = TURN
    set_steps(_remain_steps - 1)
    
    
func damage(damage: int):
    hp -= damage
    if hp < 1:
        grid.remove_unit_from_map(grid.world_to_map(translation))
        queue_free()
