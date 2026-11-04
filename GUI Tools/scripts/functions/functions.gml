/// GUI hit tests use the same coordinate space as Draw GUI.
function isInBox(xPos, yPos, x2Pos, y2Pos)
{
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    return mx >= min(xPos, x2Pos) && mx <= max(xPos, x2Pos)
        && my >= min(yPos, y2Pos) && my <= max(yPos, y2Pos);
}

function isInCircle(xPos, yPos, radius)
{
    return point_distance(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), xPos, yPos) <= radius;
}

function isInBoxWorld(xPos, yPos, x2Pos, y2Pos)
{
    return mouse_x >= min(xPos, x2Pos) && mouse_x <= max(xPos, x2Pos)
        && mouse_y >= min(yPos, y2Pos) && mouse_y <= max(yPos, y2Pos);
}

function RTRectangle(x1, y1, x2, y2, outline) { draw_rectangle(x1, y1, x2, y2, outline); }
function RTCircle(x1, y1, r, outline) { draw_circle(x1, y1, r, outline); }
function RTSprites(index, sub, x1, y1) { draw_sprite(index, sub, x1, y1); }

function GUISlider(_x1, _y1, _x2, _y2, _value)
{
    if (_x2 <= _x1) return _value;
    if (mouse_check_button(mb_left) && isInBox(_x1, _y1, _x2, _y2))
        return round(clamp((device_mouse_x_to_gui(0) - _x1) / (_x2 - _x1), 0, 1) * 255);
    return _value;
}

function GUIShapeCreate(_kind, _x, _y, _sprite)
{
    return {
        kind: _kind, x1: _x, y1: _y, x2: _x + 100, y2: _y + 100,
        r: 5, sprite: _sprite, sub: 0, _color: c_white,
        drag: 0, slider: -1, last_mx: 0, last_my: 0,
        context_open: false, cont_x: 0, cont_y: 0,
        red: 255, green: 255, blue: 255, delete_me: false
    };
}

function GUIShapeHit(_data)
{
    switch (_data.kind)
    {
        case "rectangle":
            return isInBox(_data.x1 - 5, _data.y1 - 5, _data.x2 + 5, _data.y2 + 5);
        case "circle":
            return isInCircle(_data.x1, _data.y1, _data.r + 6);
        case "sprite":
            if (!sprite_exists(_data.sprite)) return false;
            var left = _data.x1 - sprite_get_xoffset(_data.sprite);
            var top = _data.y1 - sprite_get_yoffset(_data.sprite);
            return isInBox(left, top, left + sprite_get_width(_data.sprite), top + sprite_get_height(_data.sprite));
    }
    return false;
}

/// Step captures one shape until the mouse is released.
function GUIShapeInteract(_data)
{
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var hit = GUIShapeHit(_data);
    if (!mouse_check_button(mb_left)) _data.drag = 0;
    if (_data.drag == 0 && !hit) return false;

    var mode = 5;
    if (_data.kind == "rectangle")
    {
        // Leave a movable interior even at the minimum size.
        var edge_x = min(5, (_data.x2 - _data.x1) / 4);
        var edge_y = min(5, (_data.y2 - _data.y1) / 4);
        if (my <= _data.y1 + edge_y) mode = 1;
        else if (my >= _data.y2 - edge_y) mode = 2;
        else if (mx <= _data.x1 + edge_x) mode = 3;
        else if (mx >= _data.x2 - edge_x) mode = 4;
    }
    else if (_data.kind == "circle")
    {
        var distance = point_distance(mx, my, _data.x1, _data.y1);
        if (distance >= max(_data.r / 2, _data.r - 6) && distance <= _data.r + 6) mode = 1;
    }

    if (mouse_check_button_pressed(mb_left) && hit)
    {
        _data.drag = mode;
        _data.last_mx = mx;
        _data.last_my = my;
    }

    var cursor_mode = mode;
    if (_data.drag != 0) cursor_mode = _data.drag;
    if (cursor_mode == 5) window_set_cursor(cr_size_all);
    else if (cursor_mode <= 2) window_set_cursor(cr_size_ns);
    else window_set_cursor(cr_size_we);

    if (mouse_check_button(mb_left))
    {
        if (_data.drag == 5)
        {
            var dx = mx - _data.last_mx;
            var dy = my - _data.last_my;
            _data.x1 += dx;
            _data.y1 += dy;
            _data.x2 += dx;
            _data.y2 += dy;
            _data.last_mx = mx;
            _data.last_my = my;
        }
        else if (_data.kind == "circle" && _data.drag == 1)
            _data.r = max(5, point_distance(mx, my, _data.x1, _data.y1));
        else if (_data.kind == "rectangle")
        {
            switch (_data.drag)
            {
                case 1: _data.y1 = min(my, _data.y2 - 5); break;
                case 2: _data.y2 = max(my, _data.y1 + 5); break;
                case 3: _data.x1 = min(mx, _data.x2 - 5); break;
                case 4: _data.x2 = max(mx, _data.x1 + 5); break;
            }
        }
    }
    return true;
}

function GUIContextHit(_data)
{
    return isInBox(_data.cont_x, _data.cont_y, _data.cont_x + 100, _data.cont_y + 150);
}

function GUIShapeValues(_data)
{
    var values = string(_data.x1) + "," + string(_data.y1);
    if (_data.kind == "rectangle") return values + "," + string(_data.x2) + "," + string(_data.y2);
    if (_data.kind == "circle") return values + "," + string(_data.r);
    return sprite_get_name(_data.sprite) + "," + string(_data.sub) + "," + values;
}

function GUIShapeCode(_data)
{
    var command = "draw_rectangle";
    var arguments_text = GUIShapeValues(_data);
    if (_data.kind == "circle") command = "draw_circle";
    if (_data.kind == "sprite")
    {
        return "draw_sprite_ext(" + arguments_text + ",1,1,0,make_color_rgb("
            + string(_data.red) + "," + string(_data.green) + "," + string(_data.blue) + "),1);";
    }
    return "draw_set_color(make_color_rgb(" + string(_data.red) + "," + string(_data.green)
        + "," + string(_data.blue) + "));\n" + command + "(" + arguments_text + ",false);";
}

/// Menu rows are disjoint. A captured slider continues outside its bounds.
function GUIContextInteract(_data)
{
    if (!mouse_check_button(mb_left)) _data.slider = -1;
    if (mouse_check_button_pressed(mb_left) && GUIContextHit(_data))
    {
        var row = floor((device_mouse_y_to_gui(0) - _data.cont_y) / 25);
        switch (row)
        {
            case 0:
                clipboard_set_text(GUIShapeValues(_data));
                audio_play_sound(gui_copy, 0, false);
                break;
            case 1:
                clipboard_set_text(GUIShapeCode(_data));
                audio_play_sound(gui_copy, 0, false);
                break;
            case 2:
                _data.delete_me = true;
                audio_play_sound(gui_delete, 0, false);
                break;
            default: _data.slider = clamp(row - 3, 0, 2); break;
        }
    }
    if (_data.slider >= 0 && mouse_check_button(mb_left))
    {
        var value = round(clamp((device_mouse_x_to_gui(0) - _data.cont_x - 2) / 96, 0, 1) * 255);
        switch (_data.slider)
        {
            case 0: _data.red = value; break;
            case 1: _data.green = value; break;
            case 2: _data.blue = value; break;
        }
    }
}

function GUIShapeDraw(_data)
{
    _data._color = make_color_rgb(_data.red, _data.green, _data.blue);
    draw_set_color(_data._color);
    switch (_data.kind)
    {
        case "rectangle": RTRectangle(_data.x1, _data.y1, _data.x2, _data.y2, false); break;
        case "circle": RTCircle(_data.x1, _data.y1, _data.r, false); break;
        case "sprite":
            if (sprite_exists(_data.sprite))
                draw_sprite_ext(_data.sprite, _data.sub, _data.x1, _data.y1, 1, 1, 0, _data._color, 1);
            break;
    }
}

function GUIContextDraw(_data)
{
    var cx = _data.cont_x;
    var cy = _data.cont_y;
    draw_set_color(c_gray);
    draw_set_alpha(0.9);
    draw_rectangle(cx, cy, cx + 100, cy + 150, false);
    draw_set_alpha(1);
    draw_set_color(c_green);
    draw_text(cx + 2, cy + 2, "Copy Values");
    draw_text(cx + 2, cy + 27, "Copy Code");
    draw_set_color(c_red);
    draw_text(cx + 2, cy + 52, "Delete");
    var values = [_data.red, _data.green, _data.blue];
    var colors = [c_red, c_green, c_blue];
    for (var row = 0; row < 3; row++)
    {
        draw_set_color(colors[row]);
        draw_rectangle(cx + 2, cy + 77 + row * 25, cx + 2 + 96 * values[row] / 255, cy + 100 + row * 25, false);
    }
}

function RectanglesInteract(_data) { return GUIShapeInteract(_data); }
function CirclesInteract(_data) { return GUIShapeInteract(_data); }
function SpritesInterat(_data) { return GUIShapeInteract(_data); }
function RectanglesDraw(_data) { GUIShapeDraw(_data); }
function CirclesDraw(_data) { GUIShapeDraw(_data); }
function SpritesDraw(_data) { GUIShapeDraw(_data); }
function CreateRectangle(_data) { GUIShapeInteract(_data); GUIShapeDraw(_data); }
