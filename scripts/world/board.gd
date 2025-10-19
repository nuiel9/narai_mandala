extends Node2D

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    # พื้นที่แผ่นดิน
    draw_rect(Rect2(Vector2(0,0), Vector2(1280,720)), Color(0.12,0.12,0.12)) # พื้นหลังมืด
    draw_rect(Rect2(Vector2(40,80), Vector2(1200,560)), Color(0.16,0.2,0.16)) # แผ่นดิน
    # แม่น้ำเจ้าพระยา (ทางน้ำ)
    var river: PackedVector2Array = PackedVector2Array([Vector2(620,80), Vector2(660,640)])
    draw_line(river[0], river[1], Color(0.2,0.35,0.5), 80)
    # เกาะเมือง (สี่เหลี่ยมอ่อน)
    draw_rect(Rect2(Vector2(450,220), Vector2(360,240)), Color(0.18,0.24,0.18))
    # ป้อม/ท่าเรือ (จุดหมุด)
    _pin(Vector2(470,230), "ป้อม")
    _pin(Vector2(760,430), "ท่าเรือ")
    _pin(Vector2(520,420), "คลัง")
    # กริดบาง ๆ
    for x in range(40,1240,80):
        draw_line(Vector2(x,80), Vector2(x,640), Color(1,1,1,0.04), 1)
    for y in range(80,640,80):
        draw_line(Vector2(40,y), Vector2(1240,y), Color(1,1,1,0.04), 1)

func _pin(p:Vector2, label:String) -> void:
    draw_circle(p, 8, Color(0.85,0.7,0.2))
    draw_circle(p, 4, Color(0.2,0.15,0.05))
    var font = ThemeDB.fallback_font
    draw_string(font, p + Vector2(12,4), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.9,0.9,0.9))
