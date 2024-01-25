extends Node
class_name UpgradeManager

@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: ExperienceManager
@export var upgrade_screen_scene: PackedScene

var current_upgrades := {}


func _ready() -> void:
	experience_manager.level_up.connect(on_level_up)


func on_level_up(_new_level: int):
	var chosen_upgrade := upgrade_pool.pick_random() as AbilityUpgrade
	if not chosen_upgrade:
		push_error("couldn't get chosen_upgrade")
		return

	var upgrade_screen_instance := \
		upgrade_screen_scene.instantiate() as UpgradeScreen
	add_child(upgrade_screen_instance)
	upgrade_screen_instance.set_ability_upgrades(
		[chosen_upgrade] as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)


func apply_upgrade(upgrade: AbilityUpgrade) -> void:
	var has_upgrade := current_upgrades.has(upgrade.id)
	if not has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1

	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func on_upgrade_selected(upgrade: AbilityUpgrade) -> void:
	apply_upgrade(upgrade)
