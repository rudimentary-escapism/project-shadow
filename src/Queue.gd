extends Node

var units: Array = []
var active_unit: Pawn


func next_turn() -> void:
    if is_instance_valid(active_unit):
        units.push_back(active_unit)

    if len(units) > 0:
        active_unit = units.pop_front()
        if active_unit.hp > 0:
            active_unit.start_turn()
            Events.emit_signal("unit_activated", active_unit)
        else:
            next_turn()


func add(pawn: Pawn) -> void:
    units.push_back(pawn)
    if pawn.connect("tree_exiting", self, "_on_Pawn_tree_exiting", [pawn]):
        print("Cannot see, if pawn dies")


func _ready():
    if Events.connect("turn_ended", self, "next_turn"):
        print("Cannot see, if turn is ended")
        

func _on_Pawn_tree_exiting(pawn: Pawn) -> void:
    var unit = units.find(pawn)
    if unit > -1:
        units.remove(unit)
