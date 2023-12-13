extends CharacterBody2D

const MOVE_SPEED : float = 90
const JUMP_HEIGHT : float = -200
const GRAVITY : float = 500

var accel = 0.25
var input_allowed = true
var jump_buffer_time = 0.0
var has_released_jump_button = true
var look_dir = Vector2(1, 1)
var x_dir = 1


func _physics_process(delta):
	var x_input = 0
	if input_allowed:
		x_input = Input.get_axis("left", "right")
	
	if x_input != 0:
		x_dir = x_input
	
	velocity.x = lerp(velocity.x, x_input * MOVE_SPEED, accel)
	if velocity.y < GRAVITY:
		velocity.y += GRAVITY * delta
	
	if input_allowed:
		if Input.is_action_just_pressed("jump"):
			jump_buffer_time = 8
		if Input.is_action_just_released("jump") && !has_released_jump_button:
			has_released_jump_button = true
			velocity.y = velocity.y / 2
	
	if velocity.y > 0:
		has_released_jump_button = true
	
	if jump_buffer_time > 0:
		jump_buffer_time -= 1
	
	if is_on_floor():
		if jump_buffer_time > 0:
			velocity.y = JUMP_HEIGHT
			jump_buffer_time = 0
			#$anim.play("start_jump")
			has_released_jump_button = false
			if abs(velocity.x) > MOVE_SPEED / 2:
				velocity.x = (velocity.x / abs(velocity.x)) * MOVE_SPEED * 1.5
		accel = 0.2
	else:
		accel = 0.05
	
	move_and_slide()
	Globals.player_pos = position
	
	if x_input > 0:
		$sprite.flip_h = false
	elif x_input < 0:
		$sprite.flip_h = true
	
	if x_input != 0:
		if is_on_floor():
			pass#$anim.play("walk")
	elif x_input == 0:
		if is_on_floor():
			pass#$anim.play("idle")
	if !is_on_floor():
		if velocity.y > 0:
			pass#$anim.play("fall")
	
	
	if input_allowed:
		if Input.get_axis("left", "right") != 0:
			look_dir.x = Input.get_axis("left", "right")
		look_dir.y = Input.get_axis("up", "down")
	
	if Input.is_action_pressed("test"):
		position = lerp(position, get_global_mouse_position(), 0.1)
		velocity = Vector2(0, 0)
	
	
	if Input.is_action_pressed("excavate"):
		WorldMapTools.edit_tile(get_global_mouse_position())
	
	if Input.is_action_pressed("place"):
		WorldMapTools.edit_tile(get_global_mouse_position())
