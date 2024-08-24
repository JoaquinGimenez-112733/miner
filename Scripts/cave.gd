extends Node2D
@export var fnl = FastNoiseLite.new()
var h = 40	
var w = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	setup_noise()
	#generate_cave()
	generate_better_terrain()

func setup_noise():
	fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fnl.seed = randi()
	
func generate_cave():
	$BW_Cave.clear()
	var cells = []

	for x in range(-h,h): #Pinto todo		
		for y in range(-w,w):
			$BW_Cave.set_cells_terrain_connect([Vector2i(x,y)],0,0)


	for y in range(-h + 2, h - 2): #Destruyo dentro de noise, y trazo un margen de 2 tiles
		for x in range(-w + 2, w - 2):
			var cell = Vector2i(x,y)

			var noise = fnl.get_noise_2dv(cell)
			
			if noise > .005:
				$BW_Cave.set_cells_terrain_connect([cell],0,-1)
			
	$BW_Cave.set_cells_terrain_connect(cells,0,0)
	
func _input(event : InputEvent)->void:
	if event.is_action_pressed("restart_game"):		
		get_tree().reload_current_scene()

func is_border(x,y)->bool:
	return  y in range(-h,-h+3) or x in range(-w,-w+3)  or y in range(h-3,h) or x in range(w-3,w)

func generate_better_terrain():
	var cells = []		
	for y in range(-h  , h):
		for x in range(-w, w):				
			var cell = Vector2i(x,y)
			if is_border(x,y): #bordecito
				BetterTerrain.set_cell($BetterT_Cave,cell,0)
				cells.append(cell)
				continue
				
			var noise = fnl.get_noise_2dv(cell)			
			if noise > .005: #cueva
				BetterTerrain.set_cell($BetterT_Cave,cell,0)
				cells.append(cell)
			
	BetterTerrain.update_terrain_cells($BetterT_Cave,cells)
