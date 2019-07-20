tool
extends Spatial
class_name Pawn

onready var tween: Tween = $Tween

export (int) var hp := 2
export (int) var max_steps := 5
export (int) var steps_per_turn := 2
export (String, "Ally", "Enemy") var team = "Ally" setget set_team

var remain_steps := 0
var is_action: = false


func start_turn() -> void:
    set_steps(remain_steps + steps_per_turn)
        

func set_team(value: String) -> void:
    var material = SpatialMaterial.new()
    if value == "Enemy":
        material.albedo_color = Color("#f00")
    else:
        material.albedo_color = Color("#00f")
    $MeshInstance.set_surface_material(0, material)
    team = value
                    

func set_steps(steps: int) -> void:
    remain_steps = max_steps if steps > max_steps else steps
    $Viewport/Steps.text = "steps: " + str(remain_steps)
    if remain_steps < 1:
        Events.emit_signal("turn_ended")
    
    
func move(path: Array) -> void:
    if is_action:
        return

    is_action = true
    for point in path:
        if remain_steps == 0:
            break
        step(point)
        set_steps(remain_steps - 1)
        yield(tween, "tween_all_completed")
    is_action = false


func step(point: Vector3) -> void:
    if tween.interpolate_property(self, "translation", translation,
        point, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT) and tween.start():
        return
    translation = point


func attack(pawn: Pawn) -> void:
    if remain_steps == 0 or is_action:
        return
    pawn.damage(1)
    set_steps(remain_steps - 1)
    
    
func damage(damage: int) -> void:
    hp -= damage
    $Viewport/ProgressBar.value = hp
    if hp < 1:
#        grid.remove_unit_from_map(grid.world_to_map(translation))
        queue_free()
        
        
func _ready():
    $Viewport/ProgressBar.max_value = hp
    $Viewport/ProgressBar.value = hp
