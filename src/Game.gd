extends Spatial

onready var map: = $GridMap
onready var queue: = $Queue


func _ready() -> void:
    for pawn in map.get_children():
        queue.add(pawn)
    queue.next_turn()


func _on_Camera_user_input(msg) -> void:
    var unit: Pawn = queue.active_unit
    if unit.team == "Enemy":
        return

    match msg:
        #warning-ignore:unassigned_variable
        { "move": var position }:
            var path: Array = map.find_path(unit.translation, position)
            if len(path) > 0:
                path.pop_front()
            unit.move(path)
        #warning-ignore:unassigned_variable
        { "attack": var target }:
            var path: Array = map.find_path(unit.translation, target.translation)
            if len(path) > 2:
                path.pop_front()
                path.pop_back()
                var m = unit.move(path)
                if m is GDScriptFunctionState:
                    yield(m, "completed")
            unit.attack(target)
