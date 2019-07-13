extends GridMap

signal new_unit(unit)

onready var astar = AStar.new()

export (Vector2) var map_size := Vector2(6, 6)


func _ready() -> void:
    var obstacles = get_used_cells()
    var cells = astar_add_walkable_cells(obstacles)
    astar_connect_walkable_cells(cells)
    
    for unit in get_children():
        var coordinate = world_to_map(unit.translation)
        add_unit_to_map(coordinate)
        emit_signal("new_unit", unit)
        

func add_unit_to_map(coordinate: Vector3) -> void:
    var point = Vector3(coordinate.x, 0, coordinate.z)
    var index = calculate_point_index(point)
    astar.set_point_disabled(index, true)
    

func remove_unit_from_map(coordinate: Vector3) -> void:
    var point = Vector3(coordinate.x, 0, coordinate.z)
    var index = calculate_point_index(point)
    astar.set_point_disabled(index, false)


func astar_add_walkable_cells(obstacles := []) -> Array:
    var points := []
    for y in range(map_size.y):
        for x in range(map_size.x):
            var point = Vector3(x, 0, y)
            if point in obstacles:
                continue
                
            points.append(point)
            var index = calculate_point_index(point)
            astar.add_point(index, point)
    return points
    
    
func astar_connect_walkable_cells(points: Array) -> void:
    for point in points:
        var index = calculate_point_index(point)
        var points_relative = PoolVector3Array([
            Vector3(point.x + 1, point.y, point.z),
            Vector3(point.x - 1, point.y, point.z),
            Vector3(point.x, point.y, point.z + 1),
            Vector3(point.x, point.y, point.z - 1),
        ])
        
        for point_relative in points_relative:
            var index_relative = calculate_point_index(point_relative)

            if is_outside_map_bounds(point_relative):
                continue    
            if not astar.has_point(index_relative):
                continue
            astar.connect_points(index, index_relative, false)


func can_unit_get(position: Vector3):
    var map_position = world_to_map(position)
    map_position.y = 0
    var index = calculate_point_index(map_position)
    return astar.has_point(index)


func is_outside_map_bounds(point: Vector3) -> bool:
    return point.x < 0\
        or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y

func calculate_point_index(point: Vector3) -> float:
    return point.x + map_size.x * point.z


func find_path(init_position: Vector3, target_position: Vector3) -> Array:
    var start_position = world_to_map(init_position)
    var end_position = world_to_map(target_position)
    if not astar.has_point(calculate_point_index(end_position)):
        return []
    var map_path = astar.get_point_path(
        calculate_point_index(start_position),
        calculate_point_index(end_position))
    var world_path = []
    for point in map_path:
        var point_world = map_to_world(point.x, point.y, point.z)
        world_path.append(point_world)
    return world_path
    
    
func world_to_world(old_position: Vector3) -> Vector3:
    var position = world_to_map(old_position)
    return map_to_world(position.x, 0, position.z)
    