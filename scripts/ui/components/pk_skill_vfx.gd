class_name PkSkillVfx
extends Control

signal impact
signal completed

var origin := Vector2.ZERO
var targets: Array[Vector2] = []
var element := "fire"
var basic := false
var missed := false
var playback_speed := 1.0
var elapsed := 0.0
var duration := 1.85
var hit_time := 0.82
var impacted := false
var tint := Color("ff762e")

func setup(from: Vector2, destinations: Array[Vector2], kind: String, is_basic: bool, speed: float, did_miss: bool = false) -> void:
    origin = from
    targets = destinations.duplicate()
    element = kind
    basic = is_basic
    playback_speed = speed
    missed = did_miss
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    if basic:
        duration = 0.85
        hit_time = 0.35
        tint = Color("ffe7a6")
    elif element == "water":
        tint = Color("58ddff")
    elif element == "shadow":
        tint = Color("bf78ff")
    elif element == "poison":
        tint = Color("9ce875")
    z_index = 5

func _process(delta: float) -> void:
    elapsed += delta * playback_speed
    if not impacted and elapsed >= hit_time:
        impacted = true
        impact.emit()
    queue_redraw()
    if elapsed >= duration:
        set_process(false)
        completed.emit()
        queue_free()

func _color(color: Color, alpha: float) -> Color:
    return Color(color.r,color.g,color.b,clampf(alpha,0,1))

func _glow(center: Vector2, radius: float, alpha: float, color: Color) -> void:
    for i in range(4,0,-1):
        draw_circle(center,radius*i/2.0,_color(color,alpha*(0.035 if i > 1 else 0.28)))

func _ring(center: Vector2, radius: float, alpha: float, color: Color, squash: float = 1.0) -> void:
    var points := PackedVector2Array()
    for i in range(65):
        var angle := TAU*i/64.0
        points.append(center+Vector2(cos(angle),sin(angle)*squash)*radius)
    draw_polyline(points,_color(color,alpha),2.5,true)

func _draw() -> void:
    var charge := clampf(elapsed/(hit_time*0.5),0,1)
    var arrival := clampf((elapsed-hit_time)/(duration-hit_time),0,1)
    var fade := 1.0-arrival
    if not basic:
        # The battlefield dims, while the HUD and dragons remain legible.
        draw_rect(Rect2(0,96,1280,400),Color(0.015,0.025,0.065,0.12*sin(PI*clampf(elapsed/duration,0,1))))
    if elapsed < hit_time:
        _charge(charge)
    for index in range(targets.size()):
        var target := targets[index]
        if missed:
            target += Vector2(30,-100)
        if elapsed < hit_time:
            var flight := clampf((elapsed-hit_time*0.38)/(hit_time*0.62),0,1)
            if flight > 0:
                _projectile(target,flight,index)
        elif not missed:
            if basic:
                _basic_hit(target,arrival,fade)
            elif element == "fire":
                _fire_hit(target,arrival,fade,index)
            elif element == "water":
                _water_hit(target,arrival,fade,index)
            elif element == "poison":
                _poison_hit(target,arrival,fade)
            else:
                _shadow_hit(target,arrival,fade)

func _charge(progress: float) -> void:
    var fade := 1.0-clampf(elapsed/hit_time,0,1)*0.6
    _glow(origin,18+progress*24,fade,tint)
    if basic:
        return
    _ring(origin+Vector2(0,55),30+progress*32,fade,tint,0.3)
    _ring(origin,28+progress*16,fade*0.7,tint)
    for i in range(12):
        var angle := i*TAU/12.0+elapsed*4
        var point := origin+Vector2.from_angle(angle)*(80-50*progress)
        draw_line(point,point+Vector2.from_angle(angle)*8,_color(tint,fade),2,true)

func _projectile(target: Vector2, progress: float, index: int) -> void:
    if basic:
        var head := origin.lerp(target,progress)
        draw_line(origin.lerp(target,maxf(0,progress-0.18)),head,_color(tint,0.9),5,true)
        _glow(head,12,1,tint)
        return
    if element == "fire":
        # A separate descending fire comet for every AoE victim.
        var start := origin.lerp(target,0.45)+Vector2(0,-170-index*12)
        var head := start.lerp(target,progress)
        for trail in range(12,0,-1):
            var t := maxf(0,progress-trail*0.018)
            var point := start.lerp(target,t)
            draw_circle(point,3+(12-trail)*0.8,_color(tint,(1.0-trail/13.0)*0.7))
        _glow(head,25,1,tint)
        draw_circle(head,13,Color("ff9e36"))
        draw_circle(head,6,Color("fff2a8"))
    elif element == "water":
        # A curling tide carries bright ice fragments across the arena.
        var points := PackedVector2Array()
        for i in range(33):
            var t := progress*i/32.0
            var point := origin.lerp(target,t)+Vector2(0,sin(t*TAU*2-elapsed*9)*18*sin(PI*t))
            points.append(point)
        draw_polyline(points,_color(tint,0.15),34,true)
        draw_polyline(points,_color(tint,0.65),12,true)
        draw_polyline(points,Color(0.8,0.98,1,0.9),3,true)
        var head := points[points.size()-1]
        _glow(head,26,1,tint)
        _shard(head,Vector2(9,24),0.2,tint)
    elif element == "poison":
        var head := origin.lerp(target,progress)+Vector2(0,-sin(PI*progress)*65)
        _glow(head,25,1,tint)
        draw_circle(head,10,tint)
        for i in range(7):
            var point := head+Vector2.from_angle(i*TAU/7+elapsed*4)*(12+i*2)
            draw_circle(point,3,_color(tint,0.65))
    else:
        # One concentrated dark spear, surrounded by purple lightning.
        var head := origin.lerp(target,progress)
        var direction := (target-origin).normalized()
        draw_line(origin,head,Color(0.15,0.025,0.22,0.8),27,true)
        draw_line(origin,head,_color(tint,0.7),7,true)
        draw_line(head-direction*70,head,Color("f7d5ff"),3,true)
        _glow(head,34,1,tint)
        for i in range(3):
            var points := PackedVector2Array()
            for k in range(9):
                var t := k/8.0
                points.append(origin.lerp(head,t)+direction.orthogonal()*sin(k*2.7+elapsed*24+i)*12*sin(PI*t))
            draw_polyline(points,_color(tint,0.45),2,true)

func _basic_hit(target: Vector2, progress: float, fade: float) -> void:
    var reach := 18+40*progress
    draw_line(target-Vector2(reach,reach),target+Vector2(reach,reach),_color(tint,fade),4,true)
    _ring(target,15+45*progress,fade,tint)

func _fire_hit(target: Vector2, progress: float, fade: float, index: int) -> void:
    var floor_point := target+Vector2(0,55)
    _ring(floor_point,30+100*progress,fade,tint,0.35)
    _glow(target,45+40*progress,fade,tint)
    for i in range(9):
        var x := (i-4)*15.0
        var height := (60+35*sin(i*2.1+index))*sin(PI*minf(1,progress*1.6))
        var base := floor_point+Vector2(x,0)
        var tip := base+Vector2(sin(elapsed*8+i)*12,-height-20)
        var flame := PackedVector2Array([base+Vector2(-13,0),base.lerp(tip,0.55)+Vector2(-14,-5),tip,base.lerp(tip,0.5)+Vector2(13,2),base+Vector2(13,0)])
        draw_colored_polygon(flame,_color(tint,fade*0.8))
        draw_line(base,tip,_color(Color("ffe47d"),fade),4,true)
    for i in range(20):
        var angle := i*2.39996
        var point := target+Vector2(cos(angle)*(30+progress*110),sin(angle)*(20+progress*70)-progress*40)
        draw_circle(point,(2+i%3)*fade,_color(Color("ffd57e"),fade))

func _water_hit(target: Vector2, progress: float, fade: float, index: int) -> void:
    var floor_point := target+Vector2(0,55)
    for wave in range(3):
        _ring(floor_point,25+progress*110+wave*18,fade*(1-wave*0.2),tint,0.35)
    _glow(target,65,fade,tint)
    var growth := sin(PI*clampf(progress*1.3,0,1))
    for i in range(5):
        var center := floor_point+Vector2((i-2)*26,-25*growth)
        _shard(center,Vector2(12,(35+18*sin(i*2.0+index))*growth+8),0.14*(i-2),_color(Color("a2f1ff"),fade*0.9))
    for i in range(14):
        var angle := i*TAU/14+0.2
        var point := target+Vector2.from_angle(angle)*(35+progress*90)
        _shard(point,Vector2(3,8),angle,_color(tint,fade))
    for i in range(6):
        var angle := i*TAU/6
        var end := target+Vector2.from_angle(angle)*(30+progress*25)
        draw_line(target,end,_color(Color("ecffff"),fade),2,true)

func _shadow_hit(target: Vector2, progress: float, fade: float) -> void:
    _glow(target,85,fade,tint)
    draw_circle(target,40*(1-progress),Color(0.04,0.005,0.08,fade*0.8))
    for i in range(4):
        var angle := elapsed*6+i*PI/2
        draw_arc(target,30+18*i+progress*25,angle,angle+PI*1.1,32,_color(tint,fade*(0.85-i*0.15)),3,true)
    var length := 85*minf(1,progress*5)
    for direction in [-1,1]:
        var offset := Vector2(1,direction)*length
        draw_line(target-offset,target+offset,_color(tint,fade),13,true)
        draw_line(target-offset,target+offset,_color(Color("ffe5ff"),fade),3,true)
    for i in range(15):
        var angle := i*2.39996+elapsed
        _shard(target+Vector2.from_angle(angle)*(35+progress*90),Vector2(3,12),angle,_color(tint,fade))

func _shard(center: Vector2, extent: Vector2, angle: float, color: Color) -> void:
    var points := PackedVector2Array()
    for point in [Vector2(0,-extent.y),Vector2(extent.x,0),Vector2(0,extent.y),Vector2(-extent.x,0)]:
        points.append(center+point.rotated(angle))
    draw_colored_polygon(points,color)
    draw_line(points[0],points[2],_color(Color.WHITE,color.a*0.65),1.2,true)

func _poison_hit(target: Vector2, progress: float, fade: float) -> void:
    _ring(target+Vector2(0,50),30+progress*60,fade,tint,0.35)
    for i in range(18):
        var angle := i*2.39996
        var point := target+Vector2(cos(angle)*(20+progress*65),sin(angle)*30-progress*65)
        draw_circle(point,(8+i%5)*fade,_color(tint,fade*0.28))
        draw_circle(point,2+fade,_color(Color("e2ffbd"),fade*0.8))
