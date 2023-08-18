extends Sprite2D

class_name SpriteFader

# Member variables
var timer: SceneTreeTimer = null
var lifetime: float

func _init(_lifetime: float):
	"""Constructor to save off the requested lifetime."""
	# Setup the timer
	lifetime = _lifetime

func _ready():
	"""Entering the scene - fire up the timer!"""
	timer = get_tree().create_timer(lifetime)
	timer.connect('timeout', _timer_expired)
	
func _process(delta):
	"""Set the alpha value for the sprite, based on how much time is left."""
	modulate.a = timer.time_left / lifetime

func _timer_expired():
	"""Timer has expired - clean up after ourself."""
	queue_free()
