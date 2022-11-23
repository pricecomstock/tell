extends "res://enemies/BaseMob.gd"

export var speed := 100

# Percentage of time that this enemy will move in a random direction instead of towards the player
export(float) var min_move_time := 0.2
export(float) var max_move_time := 1.0
export(float, 0, 1, 0.01) var random_direction_probability := 0.1

func _ready():
  randomize()
  movement_timer.set_one_shot(true)
  movement_timer.connect("timeout", self, "set_movement")
  set_movement()

func move_for_time(direction: Vector2, seconds: float):
  velocity = direction * speed
  movement_timer.set_wait_time(seconds)
  movement_timer.start()


func set_movement():
  var player_direction = global_position.direction_to(GlobalPlayerInfo.player_global_position())
  var move_time = rand_range(min_move_time, max_move_time)
  if (randf() < random_direction_probability):
    var move_direction = player_direction.rotated(rand_range(0.20,0.30)*TAU)
    move_for_time(move_direction, move_time)
  else:
    move_for_time(player_direction, move_time)
