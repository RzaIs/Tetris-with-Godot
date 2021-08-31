class_name Block

var TILES := []

var BORDER_X : int

var BORDER_Y : int

var CENTER : int

var COLOR : int

func _init(tiles : Array, borderX : int, borderY : int, center : int):
	for tile in tiles:
		TILES.append(tile)
	BORDER_X = borderX
	BORDER_Y = borderY
	CENTER = center

func setColor(color : int) -> void:
	COLOR = color

func rotate() -> void:
	
	if CENTER != -1:
		var rotatedTiles = []
		
		for tile in TILES:
			var newTile : Vector2 = Vector2( - tile.y + TILES[CENTER].y, tile.x - TILES[CENTER].x) + TILES[CENTER]

			rotatedTiles.append(newTile)


		TILES = rotatedTiles
		
		var C := calibrator()
		
		for index in TILES.size():
			TILES[index] += C
			
		var temp = BORDER_X
		BORDER_X = BORDER_Y
		BORDER_Y = temp

func calibrator() -> Vector2:
	var result := Vector2.ZERO
	
	var x : Array = []
	var y : Array = []
	
	for tile in TILES:
		x.append(tile.x)
		y.append(tile.y)
	
	if x.min() <= -1:
		result.x = x.min()
	elif x.max() >= 10:
		result.x = 11 - x.max()
	
	if y.min() <= -1:
		result.y = y.min()
	elif y.max() >= 17:
		result.y = 18 - y.max()
	
	return -1 * result

func setToTop() -> void:
	var y : Array = []
	for tile in TILES:
		y.append(tile.y)
	var minY = y.min() + 2
	for index in TILES.size():
			TILES[index] -= Vector2(0,minY)
