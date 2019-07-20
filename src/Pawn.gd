tool
extends Spatial
class_name Pawn

onready var tween: Tween = $Tween

export (int) var hp := 2
export (int) var max_steps := 5
export (int) var steps_per_turn := 2
export (String, "Ally", "Enemy") var team = "Ally" setget set_team

var steps := 0 setget set_steps
var is_action: = false


func start_turn() -> void:
    set_steps(steps + steps_per_turn)
        

func set_team(value: String) -> void:
    var material = SpatialMaterial.new()
    material.albedo_color = Color("#f00") if value == "Enemy" else Color("#00f")
    $MeshInstance.set_surface_material(0, material)
    team = value
                    

func set_steps(new_steps: int) -> void:
    steps = max_steps if new_steps > max_steps else new_steps
    $Viewport/Steps.text = "steps: " + str(steps)
    if steps < 1:
        Events.emit_signal("turn_ended")
    
    
func move(path: Array) -> void:
    if is_action:
        return

    is_action = true
    for point in path:
        if steps == 0:
            break
        step(point)
        yield(tween, "tween_all_completed")
        set_steps(steps - 1)
    is_action = false


func step(point: Vector3) -> void:
    if tween.interpolate_property(self, "translation", translation,
        point, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT) and tween.start():
        return
    translation = point


func attack(pawn: Pawn) -> void:
    if steps == 0 or is_action:
        return
    pawn.damage(1)
    yield(get_tree().create_timer(0.1), "timeout")
    set_steps(steps - 1)
    
    
func damage(damage: int) -> void:
    hp -= damage
    $Viewport/ProgressBar.value = hp
    if hp < 1:
        queue_free()
        
        
func _ready():
    $Viewport/ProgressBar.max_value = hp
    $Viewport/ProgressBar.value = hp
