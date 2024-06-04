extends Node2D
var noise = FastNoiseLite.new()
var terrain = []
var pixelSize = 1

var l1TextEdit
var l2TextEdit
var l3TextEdit
var waterLevelTextEdit


var size = 2048
# Called when the node enters the scene tree for the first time.
func _ready():


	l1TextEdit = get_node("Panel/TextEditL1")
	l2TextEdit = get_node("Panel/TextEditL2")
	l3TextEdit = get_node("Panel/TextEditL3")
	waterLevelTextEdit = get_node("Panel/TextEditWaterLevel")

	l1TextEdit.text = "0.02"
	l2TextEdit.text = "0.02"
	l3TextEdit.text = "0.003"
	waterLevelTextEdit.text = "0.5"

	generateTerrain()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getNoise(x, y):
	noise.frequency = float(l1TextEdit.text)
	var level1Noise = noise.get_noise_2d(x, y)

	noise.frequency = float(l2TextEdit.text)
	var level2Noise = noise.get_noise_2d(x, y)

	noise.frequency = float(l3TextEdit.text)
	var level3Noise = noise.get_noise_2d(x, y)

	var combinedNoise = level1Noise * level2Noise - level3Noise
	return combinedNoise

func generateTerrain():
	terrain = []
	for x in range(size):
		for y in range(size):
			var noiseValue = getNoise(x, y)
			terrain.append(noiseValue)

func _draw():
	draw_rect(Rect2(0, 0, size * pixelSize, size * pixelSize), Color(0.4, 0.4, 1))
	for x in range(size):
		for y in range(size):
			var noiseValue = terrain[x + y * size]
			if (noiseValue > float(waterLevelTextEdit.text)):
				draw_rect(Rect2(x* pixelSize, y* pixelSize, pixelSize, pixelSize), Color(0.4, 1, 0.4))


func _on_button_pressed():
	generateTerrain()
	queue_redraw()
