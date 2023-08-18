extends Node2D

var SpriteFader = preload('res://SpriteFader.gd')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Is the player hitting the jump (boost) button?
	if Input.is_action_just_pressed('ui_select'):
		jump()
		
		
	# Calculate the new ship velocity
	var velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Only update the position and rotation if the velocity changed
	if velocity.is_zero_approx() == false:
		velocity *= 500
		position += velocity * delta
		rotation = velocity.angle() + deg_to_rad(90)

	# Clamp the position to the screen size
	position = position.clamp(Vector2.ZERO, get_viewport_rect().size)

func jump():
	"""Handle all of the logic for moving the ship forward by 100 pixels."""
	var original_pos = position
		
	# Calculate the forward vector to jump on
	var jump_vector = Vector2.from_angle(rotation - deg_to_rad(90))
	position += jump_vector * 100
	
	# Time to spwan a trail.
	# The maximum range value is the number of image copies to create.
	for i in range(10, 0, -1):
		
		# Convert the range into floating point number. 0 - 1, inclusive.
		var factor = i / 10.0
		
		# Calculate the lifetime, in seconds, for the sprite
		# 0 is the shortest life, 0.5 is the longest life. The Factor
		# determines where in that range this particular sprite will be.
		var lifetime = lerpf(0, 0.5, factor)
		
		# Create the new sprite and set its texture, scale, and rotation
		# to match that of the player's ship sprite.
		var sprite = SpriteFader.new(lifetime)
		sprite.texture = $ShipSprite.texture
		sprite.scale = scale * $ShipSprite.scale
		sprite.rotation = rotation
		
		# The position of the stripe is somewhere between the original
		# jump location and the jump destination. Use the factor to determine
		# how far along that vector this particular sprite should go.
		sprite.position = lerp(original_pos, position, factor)
		
		# Dont' forget to add the sprite to the scene!
		get_parent().add_child(sprite)
	
	# Create a copy of the particle effect so that we can
	# have it running in multiple places at the same time
	var particle_copy = $JumpTrail.duplicate()
	particle_copy.global_position = global_position
	particle_copy.global_rotation = global_rotation
	particle_copy.emitting = true
	get_parent().add_child(particle_copy)
	
	# Sneaky way to have the particle system delete itself at the end of its lifetime
	get_tree().create_timer(particle_copy.lifetime, false).connect('timeout', particle_copy.queue_free)
