extends Control

onready var label: Label = $Label

var units: Array = []
var current_unit: Pawn


func next_turn() -> void:
    if current_unit != null:
        current_unit.end_turn()
        units.push_back(current_unit)
        current_unit = null

    var unit = units.pop_front()
    if unit != null:
        unit.start_turn()
        label.text = unit.name
        current_unit = unit


func add(unit: Pawn) -> void:
    units.push_back(unit)


func _ready():
    if units.size() == 1:
        next_turn()


func _on_EndTurnButton_pressed():
    next_turn()


func _on_GridMap_new_unit(unit: Pawn):
    add(unit)


func _on_Camera_user_input(data: Dictionary):
    if current_unit != null:
        current_unit.user_input(data)
