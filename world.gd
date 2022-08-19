extends Control

var snake_body : Array
var timer : Timer
var current_dir := Vector2(1, 0)

var current_food : Vector2

const MAP_MAX := Vector2(16, 16)

var growing : bool = false
var rng : RandomNumberGenerator

const SNAKE_TEXTURE := preload("res://asset/texture/snake_head.png")
const FOOD := preload("res://asset/texture/food.png")
const FONT := preload("res://asset/font.tres")

func _ready() :
	snake_body = [
		Vector2(8, 8)
	]
	
	timer = Timer.new()
	timer.connect("timeout", self, "_tm")
	add_child(timer)
	#timer.one_shot = true
	timer.start(0.2)
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	random_food()
	set_process(false)
	
func _tm() :
	go(current_dir)
	
func _process(delta) :
	rect_rotation += PI*6
	rect_scale = Vector2(
		sin(Time.get_ticks_msec() * 0.0001),
		cos(Time.get_ticks_msec()* 0.01)
	)
	
func die() :
	set_process(true)
	timer.stop()
	yield(get_tree().create_timer(3), "timeout")
	get_tree().quit()
	
func go(dir : Vector2) :
	var forward : Vector2 = snake_body[0] + dir
	snake_body.push_front(forward)
	
	if snake_body.find(forward, 1) != -1 :
		# ded
		die()
		return
	if (
		forward.x == -1 or forward.x == 16 or
		forward.y == -1 or forward.y == 16
	) :
		die()
		return
	
	if !growing :
		snake_body.pop_back()
	growing = false
	
	check_world()
	
func random_food() :
	while true :
		current_food = Vector2(
			rng.randi_range(0, MAP_MAX.x - 1),
			rng.randi_range(0, MAP_MAX.y - 1)
		)
		if not current_food in snake_body :
			break
	
func check_world() :
	if current_food == snake_body[0] :
		# EAT
		grow()
		random_food()
		
func grow() :
	growing = true

func _draw():
	for s in snake_body :
		draw_texture(SNAKE_TEXTURE, s * 32, Color.from_hsv(rng.randf(), 1, 1))
	draw_texture(FOOD, current_food * 32, Color.from_hsv(rng.randf(), 1, 1))
	draw_string(FONT, Vector2(64, 256), str(snake_body.size()), Color.from_hsv(rng.randf(), 1, 1))

func _physics_process(delta):
	if Input.is_action_just_pressed("move_left") :
		current_dir = Vector2(-1, 0)
	elif Input.is_action_just_pressed("move_right") :
		current_dir = Vector2(1, 0)
	elif Input.is_action_just_pressed("move_up") :
		current_dir = Vector2(0, -1)
	elif Input.is_action_just_pressed("move_down") :
		current_dir = Vector2(0, 1)
	update()
	($fuck.material as ShaderMaterial).set_shader_param('rand', rng.randf())
