extends Node2D
var tilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = get_parent().get_parent().get_parent().get_node("TileMap")
	print_debug("tilemap: ", tilemap)
func _draw():
	draw_rect(Rect2(2, 2, 1.0, 1.0), Color.GREEN)
#	draw_rect(Rect2(1.0, 1.0, 3.0, 3.0), Color.GREEN)
#	draw_rect(Rect2(5.5, 1.5, 2.0, 2.0), Color.GREEN, false, 1.0)
#	draw_rect(Rect2(9.0, 1.0, 5.0, 5.0), Color.GREEN)
#	draw_rect(Rect2(16.0, 2.0, 3.0, 3.0), Color.GREEN, false, 2.0)
	drawTilemapToMinimap()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("game_rendermap"):
		queue_redraw()
		drawTilemapToMinimap()


func drawTilemapToMinimap():
	#draw a smal rectangle for each tile in layer 1
	if (tilemap == null):
		return

	var cells = tilemap.get_used_cells(2)
	for cell in cells:
		var rect = Rect2(cell.x, cell.y, 1.0, 1.0)
		draw_rect(rect, Color.GREEN)

