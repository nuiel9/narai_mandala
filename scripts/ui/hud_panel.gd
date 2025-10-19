extends Control
@onready var next_btn: Button = $NextBtn

func _ready() -> void:
    next_btn.pressed.connect(func(): _next_turn())

func _unhandled_input(event:InputEvent) -> void:
    if event.is_action_pressed("next_turn") or event.is_action_pressed("ui_accept"):
        _next_turn()

func _next_turn() -> void:
    Turn.next_turn()
