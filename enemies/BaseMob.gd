extends KinematicBody2D

signal health_change
signal health_zero

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var movement_timer : Timer = $MovementTimer

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var velocity = Vector2.ZERO

var path : PoolVector2Array = []
var path_current_destination_inddex := 0

export var health := 1

func _ready():
  rng.randomize()
  add_to_group("enemies")
  Events.connect("player_death", self, "_on_player_death")

func _physics_process(delta):
  move_and_slide(velocity)
  
func take_damage(amount: int) -> void:
  animation_player.play('hit')

  health -= amount
  emit_signal("health_change", health)

  if (health <= 0):
    emit_signal("health_zero")
    yield(animation_player, "animation_finished")
    kill()

func take_knockback(amount, from_location: Vector2):
  var direction = from_location.direction_to(global_position)
  velocity += direction * amount

func kill() -> void:
  Events.emit_signal("enemy_killed")
  get_parent().remove_child(self)
  queue_free()

func _on_player_death(location: Vector2) -> void:
  kill()

func get_distance_to_player():
  return global_position.distance_to(GlobalPlayerInfo.player_global_position())

func navigate_to_player():
  var player_tile_position = GlobalPlayerInfo.player_tile_position()
  var mob_tile_position = GameManager.current_game_world.tile_map_ground.world_to_map(global_position)
  path = GridNavigation._calculate_path(mob_tile_position, player_tile_position)
  