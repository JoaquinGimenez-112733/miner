extends CharacterBody2D

var cs : Dictionary
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Variables para manejar los límites de zoom
var min_zoom = Vector2(0.5, 0.5)
var max_zoom = Vector2(3, 3)
var zoom_speed = 0.1
@onready var cam: Camera2D = $Camera2D

@onready var tm :TileMapLayer = get_node("../BetterT_Cave")
#@onready var tm :TileMapLayer = get_node("../BW_Cave")

func _physics_process(delta: float) -> void:
	zoom(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		if direction == -1.0:
			$AnimatedSprite2D.flip_h = true
		elif direction == 1.0:
			$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("move")
		velocity.x = direction * SPEED

	else:
		$AnimatedSprite2D.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func zoom(delta = 1):
	var zoom_amount = 2.3 * delta
	if Input.is_action_pressed("zoom_up"):		
		cam.zoom.x += zoom_amount 
		cam.zoom.y += zoom_amount
	if Input.is_action_pressed("zoom_down"):	
		if cam.zoom.x > 0.2 && cam.zoom.y > 0.2:
			cam.zoom.x -= zoom_amount
			cam.zoom.y -= zoom_amount

func _unhandled_input(event):
	if event is InputEventMouseButton: # or InputEventKey:		 
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: #or event.is_action_pressed("zoom_down") :			
			cam.zoom = (cam.zoom - Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.is_action_pressed("zoom_up"):
			cam.zoom = (cam.zoom + Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
			#
	#if event is InputEventKey:		 
		#if event.is_action_pressed("zoom_down") :			
			#cam.zoom = (cam.zoom - Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
		#elif event.is_action_pressed("zoom_up"):
			#cam.zoom = (cam.zoom + Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)

			
@warning_ignore("unused_parameter")
func _on_destroy_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			var click_pos = get_global_mouse_position()
			var cell = tm.local_to_map(click_pos)
			
			if cell != null:
				#tm.set_cells_terrain_connect([cell],0,-1, true) #Para los tm hechos con Godot puro		
#
				BetterTerrain.set_cells(tm,[cell],-1)
				BetterTerrain.update_terrain_cell(tm,cell)

			else:
				print("Cell not found at" + str(click_pos))

		
