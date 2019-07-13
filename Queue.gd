extends Node

onready var camera := $".."/Camera
onready var map := $".."/GridMap

var units: Array = []
var current_unit: Pawn


func next_turn() -> void:
    if current_unit != null:
        current_unit.end_turn()
        units.push_back(current_unit)
        current_unit = null

    var unit = units.pop_front()
    if unit != null:
        camera.get_node("Interface/DevPanel/Turn/Value").text = unit.name
        current_unit = unit
        current_unit.start_turn()


func add(unit: Pawn) -> void:
    units.push_back(unit)
    if unit.connect("changed_steps", self, "_on_Pawn_changed_steps") != 0:
        print("Couldn't connect Pawn")
    if unit.connect("tree_exiting", self, "_on_Pawn_tree_exiting", [unit]) != 0:
        print("Couldn't connect Pawn")


func _ready():
    for pawn in map.get_children():
        add(pawn)
    if units.size() > 0:
        next_turn()


func _on_EndTurnButton_pressed():
    next_turn()


func _on_Camera_user_input(data: Dictionary):
    if current_unit != null:
        current_unit.user_input(data)
        

func _on_Pawn_changed_steps(steps):
    camera.get_node("Interface/DevPanel/Steps/Value").text = str(steps)
    if steps == 0:
        next_turn()
        

func _on_Pawn_tree_exiting(pawn: Pawn) -> void:
    var unit = units.find(pawn)
    units.remove(unit)
