extends Node
class_name EnemyManager

@export var basic_enemy_scene: PackedScene
@export var arena_time_manager: ArenaTimeManager

@onready var timer: Timer = $Timer

var base_spawn_time := 0.0
var spawn_radius: int
var entities_layer: Node2D


func _ready() -> void:
	base_spawn_time = timer.wait_time

	#TODO: This needs better care. Even removing the 60 sum, enemies still spawn
	# outside the arena.
	spawn_radius = int(get_viewport() \
		.get_visible_rect() \
		.size.x / 2)

	entities_layer = get_tree() \
		.get_first_node_in_group("entities_layer")


func get_spawn_position() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Player
	if not player:
		push_error("player not found")
		return Vector2.ZERO

	var spawn_position := Vector2.ZERO
	var random_direction := Vector2.RIGHT.rotated(randf_range(0, TAU))

	for i in 4:
		spawn_position = player.global_position + \
			(random_direction * spawn_radius)

		var query_params = PhysicsRayQueryParameters2D.create(
			player.global_position,
			spawn_position,
			1)

		var raycast_result := get_tree() \
			.root \
			.world_2d \
			.direct_space_state \
			.intersect_ray(query_params)

		if raycast_result.is_empty():
			break

		random_direction = random_direction.rotated(deg_to_rad(90))

	return spawn_position


func _on_timer_timeout() -> void:
	timer.start()

	#var player := get_tree().get_first_node_in_group("player") as Player
	#if not player:
		#push_error("player not found")
		#return

	var enemy := basic_enemy_scene.instantiate() as BasicEnemy
	entities_layer.add_child(enemy)
	enemy.health_component.died.connect(_on_enemy_death)
	enemy.global_position = get_spawn_position()


func _on_enemy_death() -> void:
	pass


func _on_arena_difficulty_increased(arena_difficulty: int):
	var time_off := (0.1 / 12) * arena_difficulty
	time_off = min(time_off, 0.7)
	print("spawn time decrease: %.2fs" % time_off)
	timer.wait_time = base_spawn_time - time_off
