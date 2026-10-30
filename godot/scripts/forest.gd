extends Node2D
## Faithful Learner — first Godot gameplay foundation.
## Placeholder vector scenery will be replaced with commissioned HD assets.

const WORLD_WIDTH := 3200.0
const WALK_SPEED := 330.0
const GROUND := 560.0
var explorer_x := 150.0
var active_child := "Asher"
var discoveries: Dictionary = {}
var points := [
    {"x": 450.0, "name": "Rabbit", "fact": "Rabbits listen with their long ears.", "color": Color("#e9d5b8")},
    {"x": 1050.0, "name": "Butterfly", "fact": "Butterflies begin life as caterpillars.", "color": Color("#eaa6c9")},
    {"x": 1710.0, "name": "Bird", "fact": "Birds communicate with songs.", "color": Color("#e6b16b")},
    {"x": 2390.0, "name": "Ancient Tree", "fact": "Trees provide homes for many creatures.", "color": Color("#8dbf7b")}
]
var message := "Walk through the forest. Explore anything that glows."
var show_message_until := 0.0
var time_elapsed := 0.0
var camera: Camera2D

func _ready() -> void:
    camera = Camera2D.new()
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0
    camera.limit_left = 0
    camera.limit_right = int(WORLD_WIDTH)
    camera.limit_top = 0
    camera.limit_bottom = 720
    add_child(camera)
    camera.make_current()
    load_progress()

func _process(delta: float) -> void:
    time_elapsed += delta
    var direction := Input.get_axis("move_left", "move_right")
    explorer_x = clampf(explorer_x + direction * WALK_SPEED * delta, 45.0, WORLD_WIDTH - 45.0)
    camera.position = Vector2(explorer_x, 360)
    if Input.is_action_just_pressed("interact"):
        explore()
    queue_redraw()

func explore() -> void:
    for point in points:
        if absf(point["x"] - explorer_x) < 145.0:
            discoveries[point["name"]] = true
            message = point["name"] + ": " + point["fact"]
            show_message_until = time_elapsed + 5.0
            save_progress()
            return

func save_progress() -> void:
    var file := FileAccess.open("user://forest_" + active_child + ".json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(discoveries))

func load_progress() -> void:
    var path := "user://forest_" + active_child + ".json"
    if FileAccess.file_exists(path):
        var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
        if parsed is Dictionary:
            discoveries = parsed

func _draw() -> void:
    draw_rect(Rect2(0, 0, WORLD_WIDTH, 720), Color("#9ad4df"))
    draw_circle(Vector2(1050, 110), 65, Color("#ffe8a2"))
    for i in range(18):
        var x := float(i) * 205.0
        draw_circle(Vector2(x, 465), 170, Color("#9bcfa4"))
    draw_rect(Rect2(0, GROUND, WORLD_WIDTH, 160), Color("#659c75"))
    for i in range(28):
        var x := float(i) * 123.0
        draw_line(Vector2(x, GROUND), Vector2(x, GROUND - 175), Color("#795b43"), 23.0)
        draw_circle(Vector2(x, GROUND - 210), 82, Color("#4e906b"))
        draw_circle(Vector2(x - 35, GROUND - 190), 56, Color("#69a97a"))
    for point in points:
        var x: float = point["x"]
        var bob := sin(time_elapsed * 2.0 + x) * 9.0
        draw_circle(Vector2(x, GROUND - 70 + bob), 42, point["color"])
        draw_arc(Vector2(x, GROUND - 70 + bob), 49, 0, TAU, 32, Color("#fff5ca"), 4.0)
        if discoveries.has(point["name"]):
            draw_circle(Vector2(x, GROUND - 135), 11, Color("#f7dc74"))
    draw_circle(Vector2(explorer_x, GROUND - 75), 24, Color("#9a6a4d"))
    draw_rect(Rect2(explorer_x - 19, GROUND - 53, 38, 45), Color("#f4b86d"))
    draw_rect(Rect2(explorer_x - 15, GROUND - 8, 12, 24), Color("#364c63"))
    draw_rect(Rect2(explorer_x + 3, GROUND - 8, 12, 24), Color("#364c63"))
    var font := ThemeDB.fallback_font
    draw_string(font, Vector2(explorer_x - 40, GROUND - 115), active_child, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
    var visible_text := message if time_elapsed < show_message_until else "Walk: A/D or arrows. Discover: E or Space."
    draw_rect(Rect2(explorer_x - 350, 32, 700, 60), Color("#204b3bdc"))
    draw_string(font, Vector2(explorer_x - 330, 72), visible_text, HORIZONTAL_ALIGNMENT_LEFT, 660, 21, Color.WHITE)
    draw_string(font, Vector2(explorer_x - 330, 115), "Field journal: %d / %d" % [discoveries.size(), points.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#fff2ba"))
