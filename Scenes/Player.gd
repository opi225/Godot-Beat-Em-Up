extends KinematicBody2D
onready var label = get_node("/root/World/MainCamera/Label")

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500

export var zValue = 0.0

enum {
	MOVE,
	ATTACK,
	BACKSTEP,
}

enum {
	LEFT,
	RIGHT
}

enum attacks {
	chop,
	backKick,
	END
}

var state = MOVE
var direction = RIGHT
var velocity = Vector2.ZERO
var backstep_vector = Vector2.LEFT
var currentAttack  = attacks.END
var prevAttack = attacks.END
var nextAttack = attacks.END
var animEnd = false

onready var animationPlayer = $AnimationPlayer

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		BACKSTEP:
			backstep_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	input_vector.y = input_vector.y * 0.4
	
	if input_vector != Vector2.ZERO:
		if(input_vector.x > 0 && direction == LEFT):
			# get_node("AnimatedSprite").flip_h = false
			self.scale.x *= -1
			backstep_vector = Vector2.LEFT
			direction = RIGHT
		if(input_vector.x < 0 && direction == RIGHT):
			# get_node("AnimatedSprite").flip_h = true
			self.scale.x *= -1
			backstep_vector = Vector2.RIGHT
			direction = LEFT
		animationPlayer.play("walk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animationPlayer.play("idle")
		
	velocity = move_and_slide(velocity)
	
	velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	zValue += velocity.y
	
	if Input.is_action_just_pressed("LAttack"):
		state = ATTACK
		currentAttack = attacks.chop
		
	update_label()

func attack_state(delta):
	if currentAttack != attacks.END:
		animationPlayer.play(str(attacks.keys()[currentAttack]))
		prevAttack = currentAttack
		currentAttack = attacks.END
	
	if Input.is_action_just_pressed("LAttack"):
		match prevAttack:
			attacks.chop:
				nextAttack = attacks.backKick
			attacks.backKick:
				nextAttack = attacks.chop
		
	update_label()
	
func attack_finished():
	if nextAttack == attacks.END:
		state = MOVE
		prevAttack = attacks.END
		nextAttack = attacks.END
	else:
		currentAttack = nextAttack
		nextAttack = attacks.END

func backstep_state(delta):
	update_label()
	pass

func update_label():
	label.text = "X: " + str(position.x) + "\nY: " + str(position.y) + "\nZ: " + str(zValue) + "\nState: " + str(state) + "\nCurrent Attack: " + str(currentAttack) + "\nPrevious Attack: " + str(prevAttack) + "\nNext Attack: " + str(nextAttack) + "\n" + str(attacks.keys()[currentAttack])
