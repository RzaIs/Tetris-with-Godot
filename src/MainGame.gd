extends Node2D

var top := 2
var below := 17

var blockS1 := Block.new(
	[ Vector2(1,0), Vector2(2,0), Vector2(0,1), Vector2(1,1) ],
	2, 1, 0 )

var blockS2 := Block.new(
	[ Vector2(1,0), Vector2(2,1), Vector2(0,0), Vector2(1,1) ],
	2, 1, 0 )

var blockCube := Block.new(
	[ Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1) ],
	1, 1,-1 )

var blockLine := Block.new(
	[ Vector2(0,0), Vector2(1,0), Vector2(2,0) ],
	2, 0, 1 )

var blockL1 := Block.new(
	[ Vector2(0,0), Vector2(0,1), Vector2(1,1), Vector2(2,1) ],
	2, 1, 2 )

var blockL2 := Block.new(
	[ Vector2(2,0), Vector2(0,1), Vector2(1,1), Vector2(2,1) ],
	2, 1, 2 )

var blockT := Block.new(
	[ Vector2(0,0), Vector2(1,0), Vector2(2,0), Vector2(1,1) ],
	2, 1, 1 )

var blocks = [blockS1, blockS2, blockCube, blockLine, blockL1, blockL2, blockT]

var currentBlock := Block.new([], 0, 0,-1)

var isTimerOn := false

func _ready():
	randomize()
	currentBlock = spawnBlock(blocks[randi() % blocks.size()])

func removeBlock(block : Block):
	for tile in block.TILES:
		$TileMap.set_cell( tile.x , tile.y , -1)

func spawnBlock(block : Block):
	
	var clr = randi() % 6
	
	var result := blockCopy(block,false)
	
	var X := randi() % (10 - result.BORDER_X)
	
	for tile in block.TILES:
		result.TILES.append(tile + Vector2(X,-2))
	
	for times in randi() % 4:
		result.rotate()
		
	result.setToTop()
	
	result.setColor(clr)
	return result

func isGameOver(block : Block) -> void:
	for tile in block.TILES:
		if tile.y <= 1 and $TileMap.get_cellv(tile) != -1:
			$Timer.stop()
			isTimerOn = false

func drawBlock(block : Block) -> void:
	if isTimerOn:
		for tile in block.TILES:
			var color := block.COLOR
			$TileMap.set_cell( tile.x , tile.y , color, false, false, false, Vector2.ZERO)
	else:
		$Interface.showGameOver()

func moveBlock(block : Block) -> Block:
	
	var result := blockCopy(block, false)
	
	for tile in block.TILES:
		result.TILES.append(tile + Vector2(0,1))
		if tile.y == below - 1 or $TileMap.get_cell(tile.x, tile.y + 1) != -1:
			drawBlock(block)
			removeProcess()
			isGameOver(block)
			return spawnBlock(blocks[randi() % blocks.size()])
	
	return result

func isSideBlocked(block : Block, direction : int) -> bool:
	for tile in block.TILES:
		if $TileMap.get_cellv(tile + Vector2(direction,0)) != -1 or tile.x + direction == 10 or tile.x + direction == -1:
			return true
	return false
	
func slideBlock(block : Block, direction : int) -> Block:
	
	var result := blockCopy(block, false)
	
	if not isSideBlocked(block , direction):
		for tile in block.TILES:
			result.TILES.append(tile + Vector2(direction,0))
	else:
		return block
	
	return result

func isRotatable(block : Block):
	var tempBlock := blockCopy(block,true)
	tempBlock.rotate()
	for tile in tempBlock.TILES:
		if $TileMap.get_cellv(tile) != -1:
			return false
	return true

func rotateBlock(block : Block) -> Block:
	if isRotatable(block):
		block.rotate()
	return block

func removeAndSlide(lineIndex : int) -> void:
	for x in 10:
		$TileMap.set_cell(x, lineIndex, 6, false, false, false)
	yield(get_tree().create_timer(0.2), "timeout")
	for y in range(lineIndex,1,-1):
		for x in 10:
			if $TileMap.get_cell(x,y) != -1 and not Vector2(x,y)  in currentBlock.TILES:
				if $TileMap.get_cell(x,y-1) != -1 and not Vector2(x,y-1)  in currentBlock.TILES:
					$TileMap.set_cell(x, y, $TileMap.get_cell(x,y-1), false, false, false)
				elif $TileMap.get_cell(x,y-1) == -1:
					$TileMap.set_cell(x, y, -1, false, false, false)
			elif $TileMap.get_cell(x,y) == -1:
				if $TileMap.get_cell(x,y-1) != -1 and not Vector2(x,y-1)  in currentBlock.TILES:
					$TileMap.set_cell(x, y, $TileMap.get_cell(x,y-1), false, false, false)

func checkRemovableLine() -> Array:
	var result := []
	for y in range(2,17):
		var isLineFull = true
		for x in 10:
			if $TileMap.get_cell(x,y) == -1:
				isLineFull = false
		if isLineFull:
			result.append(y)
	return result

func removeProcess():
	$Timer.stop()
	var lines := checkRemovableLine()
	if not lines.empty():
		for lineIndex in range(lines.size()):
			removeAndSlide(lines[lineIndex])
			$Interface.updateScore()
	$Timer.start()

func _process(_delta) -> void:
	if isTimerOn:
		if Input.is_action_just_pressed("LEFT") or Input.is_action_just_pressed("RIGHT"):
			var Left : int = ceil(Input.get_action_strength("LEFT")) as int
			var Right : int = ceil(Input.get_action_strength("RIGHT")) as int
			removeBlock(currentBlock)
			currentBlock = slideBlock(currentBlock, Right - Left)
			drawBlock(currentBlock)
		if Input.is_action_just_pressed("ROTATE"):
			removeBlock(currentBlock)
			currentBlock = rotateBlock(currentBlock)
			drawBlock(currentBlock)
		if Input.is_action_pressed("SPEED_UP"):
			$Timer.wait_time = 0.2
		else:
			$Timer.wait_time = 0.5

func _on_Timer_timeout():
	removeBlock(currentBlock)
	currentBlock = moveBlock(currentBlock)
	drawBlock(currentBlock)


func blockCopy(block : Block, withArray : bool) -> Block:
	var result : Block
	
	if withArray:
		result = Block.new(block.TILES.duplicate(true), block.BORDER_X, block.BORDER_Y, block.CENTER)
	else:
		result = Block.new([], block.BORDER_X, block.BORDER_Y, block.CENTER)
	result.setColor(block.COLOR)
	return result


func _on_restart():
	clearTiles()
	isTimerOn = true
	$Timer.start()
	_ready()

func clearTiles():
	for y in 19:
		for x in 10:
			$TileMap.set_cell(x, y-1, -1, false, false, false)
