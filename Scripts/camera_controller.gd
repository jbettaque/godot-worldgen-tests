extends Node
var speed = 900
var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_viewport().get_camera_2d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# move camera with wasd
	if Input.is_action_pressed("ui_right"):
		camera.position.x += speed * delta
	if Input.is_action_pressed("ui_left"):
		camera.position.x -= speed * delta
	if Input.is_action_pressed("ui_down"):
		camera.position.y += speed * delta
	if Input.is_action_pressed("ui_up"):
		camera.position.y -= speed * delta
	if Input.is_action_just_released("MWU"):
		if (camera.zoom.x == -1):
			pass
		else:
			camera.zoom += Vector2(1, 1)
	if Input.is_action_just_released("MWD"):
		if (camera.zoom.x == 1):
			pass
		else:
			camera.zoom -= Vector2(1, 1)
		


