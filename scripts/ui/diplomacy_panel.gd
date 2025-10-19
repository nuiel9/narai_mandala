extends Panel

const NAMES := {"dutch":"ดัตช์","fr":"ฝรั่งเศส","persia":"เปอร์เซีย"}
@onready var box: VBoxContainer = $VBox/Factions

func _ready() -> void:
    for f in ["dutch","fr","persia"]:
        _add_row(f)
    Diplomacy.relation_changed.connect(_on_change)

func _unhandled_input(event:InputEvent) -> void:
    if event.is_action_pressed("toggle_diplomacy"):
        visible = !visible

func _add_row(f:String) -> void:
    var hb = HBoxContainer.new()
    hb.custom_minimum_size.x = 320
    var lbl = Label.new()
    lbl.text = NAMES.get(f, f) + ":"
    lbl.custom_minimum_size.x = 90
    hb.add_child(lbl)
    var stats = Label.new()
    stats.name = f + "_stats"
    stats.text = _fmt(f)
    hb.add_child(stats)
    for t in ["port_rights","mil_advisor","trade_privilege"]:
        var b = Button.new()
        b.text = t
        b.pressed.connect(func(): Diplomacy.apply_treaty(t, f))
        hb.add_child(b)
    box.add_child(hb)

func _fmt(f:String) -> String:
    var d = Diplomacy.get_relation(f)
    if d.is_empty(): return "-"
    return "favor:%d fear:%d profit:%d" % [d["favor"], d["fear"], d["profit"]]

func _on_change(f:String, _a:int, _b:int, _c:int) -> void:
    var n = box.get_node_or_null("%s_stats" % f)
    if n and n is Label:
        n.text = _fmt(f)
