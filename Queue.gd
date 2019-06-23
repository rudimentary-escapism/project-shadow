extends Control

onready var label: Label = $Label

var units: Array = ['player', 'enemy1']


func next_turn() -> void:
    var unit = units.pop_front()
    label.text = str(unit)
    units.push_back(unit)


func _ready():
    next_turn()


func _on_EndTurnButton_pressed():
    next_turn()
