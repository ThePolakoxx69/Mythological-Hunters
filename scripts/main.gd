extends Node2D

# Mythological Hunters - first exploration prototype.
# This prototype uses drawn placeholder graphics so it has no external asset dependencies.

const WORLD_SIZE := Vector2(320, 180)
const PLAYER_SPEED := 58.0
const PLAYER_SIZE := Vector2(8, 10)
const GRASS_ZONE := Rect2(184, 42, 86, 72)

var player_position := Vector2(68, 98)
var encounter_message := ""
var encounter_timer := 0.0
var rng := RandomNumberGenerator.new()
var touch_direction := Vector2.ZERO

func _ready() -> void:
	rng.randomize()
	queue_redraw()

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	direction += touch_direction
	if direction.length() > 1.0:
		direction = direction.normalized()

	player_position += direction * PLAYER_SPEED * delta
	player_position.x = clampf(player_position.x, 8.0, WORLD_SIZE.x - 8.0)
	player_position.y = clampf(player_position.y, 30.0, WORLD_SIZE.y - 12.0)

	if encounter_timer > 0.0:
		encounter_timer -= delta
		if encounter_timer <= 0.0:
			encounter_message = ""

	if direction != Vector2.ZERO and GRASS_ZONE.has_point(player_position) and encounter_timer <= 0.0:
		if rng.randf() < 0.018:
			encounter_message = "¡Algo se mueve entre la hierba!"
			encounter_timer = 2.8

	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_update_touch_direction(event.position)
		else:
			touch_direction = Vector2.ZERO
	elif event is InputEventScreenDrag:
		_update_touch_direction(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			encounter_message = ""
			encounter_timer = 0.0

func _update_touch_direction(screen_position: Vector2) -> void:
	var view_size := get_viewport_rect().size
	var scale_x := view_size.x / WORLD_SIZE.x
	var scale_y := view_size.y / WORLD_SIZE.y
	var point := Vector2(screen_position.x / scale_x, screen_position.y / scale_y)

	# Simple virtual D-pad on the lower-left side of the screen.
	if point.x < 94.0 and point.y > 112.0:
		var center := Vector2(48, 145)
		var delta := point - center
		if delta.length() < 34.0:
			if absf(delta.x) > absf(delta.y):
				touch_direction = Vector2(signf(delta.x), 0)
			else:
				touch_direction = Vector2(0, signf(delta.y))
			return
	touch_direction = Vector2.ZERO

func _draw() -> void:
	_draw_world()
	_draw_player()
	_draw_interface()

func _draw_world() -> void:
	# Grass ground and simple pixel-art paths.
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#477b4a"))
	for y in range(24, 180, 12):
		for x in range(0, 320, 16):
			var shade := Color("#4b824d") if ((x + y) / 4) % 2 == 0 else Color("#437346")
			draw_rect(Rect2(x, y, 8, 4), shade)

	# Path through the village and into the wilds.
	draw_rect(Rect2(0, 78, 205, 27), Color("#b9a078"))
	draw_rect(Rect2(92, 102, 27, 78), Color("#b9a078"))
	for x in range(0, 205, 16):
		draw_rect(Rect2(x, 83, 8, 2), Color("#cbb58e"))

	# Tall grass encounter zone.
	draw_rect(GRASS_ZONE, Color("#326641"))
	for y in range(46, 108, 8):
		for x in range(188, 266, 8):
			draw_rect(Rect2(x, y, 3, 6), Color("#76a34e"))
			draw_rect(Rect2(x + 3, y + 2, 2, 4), Color("#9abd5c"))

	# Small pond.
	draw_rect(Rect2(246, 126, 56, 34), Color("#345f83"))
	draw_rect(Rect2(250, 130, 48, 26), Color("#4c8ab0"))
	draw_rect(Rect2(258, 134, 12, 2), Color("#8cc5d3"))
	draw_rect(Rect2(278, 146, 10, 2), Color("#8cc5d3"))

	# Village houses.
	_draw_house(Vector2(24, 38), Color("#a65d45"))
	_draw_house(Vector2(76, 38), Color("#80634b"))
	_draw_tree(Vector2(144, 48))
	_draw_tree(Vector2(164, 56))
	_draw_tree(Vector2(286, 42))
	_draw_tree(Vector2(302, 62))

func _draw_house(position: Vector2, wall_color: Color) -> void:
	draw_rect(Rect2(position + Vector2(2, 5), Vector2(28, 20)), wall_color)
	draw_rect(Rect2(position, Vector2(32, 8)), Color("#563d37"))
	draw_rect(Rect2(position + Vector2(5, 8), Vector2(6, 6)), Color("#b7d5d8"))
	draw_rect(Rect2(position + Vector2(21, 13), Vector2(6, 12)), Color("#553c32"))

func _draw_tree(position: Vector2) -> void:
	draw_rect(Rect2(position + Vector2(5, 9), Vector2(4, 12)), Color("#65472f"))
	draw_rect(Rect2(position, Vector2(14, 12)), Color("#28543a"))
	draw_rect(Rect2(position + Vector2(3, 2), Vector2(9, 7)), Color("#397447"))

func _draw_player() -> void:
	var p := player_position
	# Shadow, body, head and backpack.
	draw_rect(Rect2(p + Vector2(-5, 5), Vector2(10, 3)), Color("#31513b"))
	draw_rect(Rect2(p + Vector2(-4, -2), Vector2(8, 8)), Color("#d0a15d"))
	draw_rect(Rect2(p + Vector2(-3, -8), Vector2(6, 6)), Color("#e6bd8b"))
	draw_rect(Rect2(p + Vector2(-4, -9), Vector2(8, 3)), Color("#493d35"))
	draw_rect(Rect2(p + Vector2(-6, -1), Vector2(3, 6)), Color("#a84d3f"))
	draw_rect(Rect2(p + Vector2(-2, 1), Vector2(4, 3)), Color("#426e91"))

func _draw_interface() -> void:
	draw_rect(Rect2(0, 0, 320, 22), Color("#17251f"))
	draw_string(ThemeDB.fallback_font, Vector2(8, 14), "MYTHOLOGICAL HUNTERS", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#f2e6c9"))
	draw_string(ThemeDB.fallback_font, Vector2(8, 30), "Pueblo de prueba", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#ffffff"))

	# Touch D-pad.
	draw_rect(Rect2(28, 126, 40, 38), Color(0.08, 0.12, 0.10, 0.72))
	draw_rect(Rect2(39, 129, 18, 32), Color("#c5c8b4"))
	draw_rect(Rect2(32, 136, 32, 18), Color("#c5c8b4"))
	draw_rect(Rect2(43, 133, 10, 24), Color("#647768"))
	draw_rect(Rect2(36, 140, 24, 10), Color("#647768"))
	draw_string(ThemeDB.fallback_font, Vector2(86, 169), "MUEVETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#f2e6c9"))

	if not encounter_message.is_empty():
		draw_rect(Rect2(48, 66, 224, 34), Color("#18251f"))
		draw_rect(Rect2(50, 68, 220, 30), Color("#e7dec4"))
		draw_string(ThemeDB.fallback_font, Vector2(58, 86), encounter_message, HORIZONTAL_ALIGNMENT_LEFT, 204, 8, Color("#25372b"))
