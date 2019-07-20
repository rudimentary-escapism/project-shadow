extends Spatial

onready var map: = $GridMap
onready var queue: = $Queue


func _ready() -> void:
    for pawn in map.get_children():
        queue.add(pawn)
    queue.next_turn()
    if Events.connect("unit_activated", self, "_on_unit_activated"):
        print("Cannot see, if unit is activated")
    

func _on_unit_activated(pawn: Pawn) -> void:
    if pawn.team == "Enemy":
        while pawn.steps > 0:
            var allies = map.enemies("Ally")
            if len(allies) == 0:
                break
            print(allies)
            var target = map.search_nearest(allies, pawn.translation)
            if target == null:
                return
            var a = attack(pawn, target)
            if a is GDScriptFunctionState:
                yield(a, "completed")
            
        


func _on_Camera_user_input(msg) -> void:
    var pawn: Pawn = queue.active_unit
    if not is_instance_valid(pawn):
        queue.next_turn()
        return
        
    if pawn.team == "Enemy":
        return

    match msg:
        #warning-ignore:unassigned_variable
        { "move": var position }:
            var path: Array = map.find_path(pawn.translation, position)
            if len(path) > 0:
                path.pop_front()
            pawn.move(path)
        #warning-ignore:unassigned_variable
        { "attack": var target }:
            attack(pawn, target)
            

func attack(attacker: Pawn, target: Pawn):
    var path: Array = map.find_path(attacker.translation, target.translation)
    if len(path) > 2:
        path.pop_front()
        path.pop_back()
        var m = attacker.move(path)
        if m is GDScriptFunctionState:
            yield(m, "completed")
    var a = attacker.attack(target)
    if a is GDScriptFunctionState:
        yield(a, "completed")
