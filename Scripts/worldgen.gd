extends Node2D
var tilemap
var camera

var tile_water = 14
var chunk_size = 8
var render_distance = 10
var noise = FastNoiseLite.new()
var random = RandomNumberGenerator.new()

var chunkRenderQueue = []
var lastChunkRendered = 0
var chunkRenderingDelay = 0

var standingStillFor = 0
var lastCameraPos
var noisePreview = true
var noisePreviewControl = null
var noisePreviewData = []
var lastNoisePreviewRendered = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize()
	noise.set_seed(random.randi())
	tilemap = get_node("TileMap")
	camera = get_viewport().get_camera_2d()
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	lastCameraPos = camera.position
	noisePreviewControl = get_node("NoisePreview")


#	if (FileAccess.file_exists("test.json")):
#		loadMap("test.json", tilemap)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

	processChunkQueue()



	var chunkX = int(tilemap.local_to_map(camera.position).x / chunk_size)
	var chunkY = int(tilemap.local_to_map(camera.position).y / chunk_size)

	#generate chunk the camera is in


#	 generate chunks around the camera in a circle
	for i in range(0, render_distance):
		for j in range(0, render_distance):
			if (i * i + j * j < render_distance * render_distance):
				queueChunkGen(chunkX + i, chunkY + j)
				queueChunkGen(chunkX - i, chunkY - j)
				queueChunkGen(chunkX + i, chunkY - j)
				queueChunkGen(chunkX - i, chunkY + j)

	if (lastCameraPos == camera.position):
		standingStillFor += delta
	else:
		standingStillFor = 0
		
	lastCameraPos = camera.position

	#check if the camera has been standing still for a while
	#and if so, generate chunks around the camera
	
#	var extendedRenderDistance = render_distance * (1 + standingStillFor * 0.1)
#	if (extendedRenderDistance > render_distance * 10):
#		extendedRenderDistance = render_distance * 10
#
#	for i in range(0, extendedRenderDistance):
#			for j in range(0, extendedRenderDistance):
#				if (i * i + j * j < extendedRenderDistance * extendedRenderDistance):
#					queueChunkGen(chunkX + i, chunkY + j)
#					queueChunkGen(chunkX - i, chunkY - j)
#					queueChunkGen(chunkX + i, chunkY - j)
#					queueChunkGen(chunkX - i, chunkY + j)


	handleKeybinds(delta)





func generateChunk(chunkX, chunkY):

	var chunk = Vector2i(chunkX, chunkY)

	var cells = []
	var cells2 = []
	var cells3 = []
	

	for i in range(0, chunk_size):
		for j in range(0, chunk_size):

			var cell = Vector2i(i + chunkX * chunk_size, j + chunkY * chunk_size)
			#set water to layer 0
			tilemap.set_cell(0, cell, tile_water, Vector2i(0, 0))
			var combinedNoise = getNoise(cell.x, cell.y)
			if (combinedNoise > 0.4):
				cells2.append(cell)
#			if (level2Noise > 0.2):
#				cells3.append(cell)

#	print_debug("Time elapsed before drawing: " + str(Time.get_ticks_msec()))
#	tilemap.set_cells_terrain_connect(1, cells, 0, 0)
#	BetterTerrain.set_cells(tilemap, 1, cells, 0)
#	BetterTerrain.update_terrain_cells(tilemap, 1, cells)

	BetterTerrain.set_cells(tilemap, 2, cells2, 0)
	BetterTerrain.update_terrain_cells(tilemap, 2, cells2)




func queueChunkGen(chunkX, chunkY):
	var chunk = Vector2i(chunkX, chunkY)
	
	#check the tilemap if the chunk is already generated
	if (tilemap.get_cell_source_id(0, chunk * chunk_size) != -1):
		return

	#check if the chunk is already in the queue
	for i in range(0, chunkRenderQueue.size()):
		if (chunkRenderQueue[i] == chunk):
			return

	chunkRenderQueue.append(chunk)

func processChunkQueue():
	if (chunkRenderQueue.size() == 0):
		return
	if (Time.get_ticks_msec() - chunkRenderingDelay < lastChunkRendered):
		return

	var chunk = chunkRenderQueue.pop_front()
	generateChunk(chunk.x, chunk.y)
	
	lastChunkRendered = Time.get_ticks_msec()

func saveMap(path:String, tile_map:TileMap) -> void:
	# Get the number of layers
	var layers = tile_map.get_layers_count()
	var tile_map_layers = []
	# Resize the array to the number of layers
	tile_map_layers.resize(layers)

	# Get the tile_data from each layer
	for layer in layers:
		tile_map_layers[layer] = tile_map.get("layer_%s/tile_data" % layer)

	var saveFileJSON: Dictionary = {
		"layer_data": tile_map_layers,
		"seed": noise.get_seed(),
		"chunk_size": chunk_size,
	}
	
	# Save the array to a file as a JSON
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(saveFileJSON))
	file.close()


func loadMap(path:String, tile_map:TileMap) -> void:
	# Read the file as a String and parse the JSON
	var saveFileJSON = JSON.parse_string(FileAccess.get_file_as_string(path))
	var layer_data = saveFileJSON.layer_data
	noise.set_seed(saveFileJSON.seed)
	chunk_size = saveFileJSON.chunk_size

	# For each entry in the array, set the tilemap layer tile_data
	for layer in layer_data.size():
		var tiles = layer_data[layer]
		tile_map.set('layer_%s/tile_data' % layer, tiles)



func handleKeybinds(delta):
	if (Input.is_action_just_pressed("game_save")):
		saveMap("test.json", tilemap)
		print_debug("Map saved")
	if (Input.is_action_just_pressed("game_load")):
		loadMap("test.json", tilemap)
		print_debug("Map loaded")

func getNoise(x, y):


	noise.frequency = 0.02
	var level1Noise = noise.get_noise_2d(x, y)
#	var level1NoiseTexture = NoiseTexture2D.new()
#	level1NoiseTexture.noise = noise
#	await level1NoiseTexture.changed

	noise.frequency = 0.02
	var level2Noise = noise.get_noise_2d(x, y)
#	var level2NoiseTexture = NoiseTexture2D.new()
#	level2NoiseTexture.noise = noise
#	await level2NoiseTexture.changed

	noise.frequency = 0.003
	var level3Noise = noise.get_noise_2d(x, y)
#	var level3NoiseTexture = NoiseTexture2D.new()
#	level3NoiseTexture.noise = noise
#	await level3NoiseTexture.changed

	var combinedNoise = level1Noise * level2Noise - level3Noise
#	var combinedNoiseTexture = level1NoiseTexture.get_data()
#	for i in range(0, combinedNoiseTexture.size()):
#		combinedNoiseTexture[i] = combinedNoise
#	combinedNoiseTexture.set_data(combinedNoiseTexture)
	return combinedNoise

