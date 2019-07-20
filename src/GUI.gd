extends CanvasLayer

func _ready():
    if Events.connect("mouse_targeted", self, "_on_mouse_targeted"):
        print("Cannot see mouse target")
    if Events.connect("unit_activated", self, "_on_unit_activated"):
        print("Cannot see active unit")


func _on_mouse_targeted(text: String):
    $DevPanel/Mouse/Target.text = text
    

func _on_unit_activated(pawn: Pawn):
    $DevPanel/Turn/Value.text = pawn.name


func _on_EndTurnButton_pressed():
    Events.emit_signal("turn_ended")
