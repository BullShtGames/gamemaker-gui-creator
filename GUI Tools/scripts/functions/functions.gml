/// @function                 isInBox;
/// @param {real}  xPos Top left horizontal corner of the area
/// @param {real}  yPos Top left vertical corner of the area
/// @param {real}  x2Pos Bottom right horizontal corner of the area
/// @param {real}  y2Pos Bottom right vertical corner of the area
/// @description              GUI USE ONLY: Checks if the mouse is inside the given rectangle
function isInBox(xPos,yPos,x2Pos,y2Pos)
{
if (window_mouse_get_x() > xPos && window_mouse_get_y() > yPos && window_mouse_get_x() < x2Pos && window_mouse_get_y() < y2Pos)
{
	return true;
}
}

/// @function                 isInBoxWorld;
/// @param {real}  xPos Top left horizontal corner of the area
/// @param {real}  yPos Top left vertical corner of the area
/// @param {real}  x2Pos Bottom right horizontal corner of the area
/// @param {real}  y2Pos Bottom right vertical corner of the area
/// @description   Checks if the mouse is inside the given rectangle within the room
function isInBoxWorld(xPos,yPos,x2Pos,y2Pos)
{
	if (mouse_x > xPos && mouse_y > yPos && mouse_x < x2Pos && mouse_y < y2Pos)
	{
		return true;
	}
}


/// @function                 RTRectangle;
/// @param {real}  x1 Top left horizontal corner of the area
/// @param {real}  y1 Top left vertical corner of the area
/// @param {real}  x2 Bottom right horizontal corner of the area
/// @param {real}  y2 Bottom right vertical corner of the area
/// @description   This function gets called when using the realtime editor
function RTRectangle(x1,y1,x2,y2,outline)
{
	draw_rectangle(x1,y1,x2,y2,outline)
}

/// @function                 RTCircle;
/// @param {real}  x1 Top left horizontal corner of the area
/// @param {real}  y1 Top left vertical corner of the area
/// @param {real}  x2 Bottom right horizontal corner of the area
/// @param {real}  y2 Bottom right vertical corner of the area
/// @description   This function gets called when using the realtime editor
function RTCircle(x1,y1,r,outline)
{
	draw_circle(x1,y1,r,outline)
}


/// @function                 GUISlider;
/// @param {real}  _x1 Top left horizontal corner of the area
/// @param {real}  _y1 Top left vertical corner of the area
/// @param {real}  _x2 Bottom right horizontal corner of the area
/// @param {real}  _y2 Bottom right vertical corner of the area
/// @param {real}  _value Value of the slider
/// @description   This function gets called when using the realtime editor
function GUISlider(_x1, _y1, _x2, _y2, _value)
{
    var mx = device_mouse_x_to_gui(0);
    
    if (mouse_check_button(mb_left))
    {
        if (isInBox(_x1, _y1 - 5, _x2, _y2 + 5))
        {
            var t = (mx - _x1) / (_x2 - _x1);
            t = clamp(t, 0, 1);

            _value = round(t * 255);
        }
    }

    return _value;
}
/// @function                 CreateRectangle;
/// @param {real}  _rect this passes the array to the func
/// @description   This function gets called when using the realtime editor
function CreateRectangle(_rect)
{
	static pad = 2;
	static bsize = 25;
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
	_rect._color = make_color_rgb(_rect.red,_rect.green,_rect.blue);
	var red_slider_x1 = _rect.cont_x + pad;
	var red_slider_x2 = _rect.cont_x + 100 - pad;
	var red_x2 = lerp(red_slider_x1, red_slider_x2, _rect.red / 255);
	var green_slider_x1 = _rect.cont_x + pad;
	var green_slider_x2 = _rect.cont_x + 100 - pad;
	var green_x2 = lerp(green_slider_x1, green_slider_x2, _rect.green / 255);
	var blue_slider_x1 = _rect.cont_x + pad;
	var blue_slider_x2 = _rect.cont_x + 100 - pad;
	var blue_x2  = lerp(blue_slider_x1, blue_slider_x2, _rect.blue  / 255);
	
        if (isInBox(_rect.x1 - 5, _rect.y1 - 5, _rect.x2 + 5, _rect.y1 + 5))//top
        {
			if (mouse_check_button_pressed(mb_left)) {_rect.drag = 1;}
			window_set_cursor(cr_size_ns);
        }
        else if (isInBox(_rect.x1 - 5, _rect.y2 - 5, _rect.x2 + 5, _rect.y2 + 5))//bottom
        {
            if (mouse_check_button_pressed(mb_left)) {_rect.drag = 2;}
			window_set_cursor(cr_size_ns);
        }
        else if (isInBox(_rect.x1 - 5, _rect.y1, _rect.x1 + 5, _rect.y2))//left
        {
            if (mouse_check_button_pressed(mb_left)) {_rect.drag = 3;}
			window_set_cursor(cr_size_we);
        }
        else if (isInBox(_rect.x2 - 5, _rect.y1, _rect.x2 + 5, _rect.y2))//right
        {
            if (mouse_check_button_pressed(mb_left)) {_rect.drag = 4;}
            window_set_cursor(cr_size_we);
        }
		else if (isInBox(_rect.x1, _rect.y1, _rect.x2, _rect.y2))
		{
		    if (mouse_check_button_pressed(mb_left))
		    {
		        _rect.drag = 5;
				_rect.last_mx = mx;
				_rect.last_my = my;
		    }
			window_set_cursor(cr_size_all);
		}
    if (mouse_check_button(mb_left))
    {
        switch (_rect.drag)
        {
            case 1:
                _rect.y1 = my
            break;

            case 2:
                _rect.y2 = my;
            break;

            case 3:
                _rect.x1 = mx;
            break;

            case 4:
                _rect.x2 = mx;
            break;
			case 5:
				if (_rect.context_open == true){_rect.context_open = false}
	            var dx = mx - _rect.last_mx;
	            var dy = my - _rect.last_my;

	            _rect.x1 += dx;
	            _rect.x2 += dx;
	            _rect.y1 += dy;
	            _rect.y2 += dy;

	            _rect.last_mx = mx;
	            _rect.last_my = my;
			break;
        }
    }
    else
    {
        _rect.drag = 0;
        window_set_cursor(cr_default);
    }
		draw_set_colour(_rect._color);
        RTRectangle(_rect.x1,_rect.y1,_rect.x2,_rect.y2,false);
		
	if (isInBox(_rect.x1, _rect.y1, _rect.x2, _rect.y2))
	{
		if (mouse_check_button_pressed(mb_right))
		{
		_rect.cont_x = window_mouse_get_x()
		_rect.cont_y = window_mouse_get_y()
		_rect.context_open = !_rect.context_open
		}
	}
	if (_rect.context_open == true)
	{
		draw_set_alpha(0.5)
		draw_rectangle_colour(_rect.cont_x,_rect.cont_y,_rect.cont_x+100,_rect.cont_y+150,c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad,_rect.cont_x+100-pad,_rect.cont_y+bsize,c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+bsize,_rect.cont_x+100-pad,_rect.cont_y+(bsize*2),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*2),_rect.cont_x+100-pad,_rect.cont_y+(bsize*3),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*3),_rect.cont_x+100-pad,_rect.cont_y+(bsize*4),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*4),_rect.cont_x+100-pad,_rect.cont_y+(bsize*5),c_gray,c_gray,c_gray,c_gray,false);
		draw_set_alpha(1)
		//copy
		if (isInBox(_rect.cont_x+pad,_rect.cont_y+pad,_rect.cont_x+100-pad,_rect.cont_y+bsize))
		{
			if mouse_check_button_pressed(mb_left)
			{
				clipboard_set_text(string(_rect.x1)+","+string(_rect.y1)+","+string(_rect.x2)+","+string(_rect.y2));
				audio_play_sound(gui_copy,0,0);
			}
		}
		//delete
		if (isInBox(_rect.cont_x+pad,_rect.cont_y+pad+bsize,_rect.cont_x+100-pad,_rect.cont_y+(bsize*2)))
		{
			if mouse_check_button_pressed(mb_left)
			{
				_rect.delete_me = true;
				audio_play_sound(gui_delete,0,0);
			}
		}
		//RGB
		_rect.red = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*3),_rect.cont_x+100-pad,_rect.cont_y+(bsize*4),_rect.red);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*3),red_x2,_rect.cont_y+(bsize*4),c_red,c_red,c_red,c_red,false);
		_rect.green = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*4),_rect.cont_x+100-pad,_rect.cont_y+(bsize*5),_rect.green);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*4),green_x2,_rect.cont_y+(bsize*5),c_green,c_green,c_green,c_green,false);
		_rect.blue = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*5),_rect.cont_x+100-pad,_rect.cont_y+(bsize*6),_rect.blue);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*5),blue_x2,_rect.cont_y+(bsize*6),c_blue,c_blue,c_blue,c_blue,false);
	}
}

/// @function                 RectanglesDraw;
/// @param {real}  _rect this passes the array to the func
/// @description   This function gets called when using the realtime editor
function RectanglesDraw(_rect)
{
	static pad = 2;
	static bsize = 25;
	_rect._color = make_color_rgb(_rect.red,_rect.green,_rect.blue);
	var red_slider_x1 = _rect.cont_x + pad;
	var red_slider_x2 = _rect.cont_x + 100 - pad;
	var red_x2 = lerp(red_slider_x1, red_slider_x2, _rect.red / 255);
	var green_slider_x1 = _rect.cont_x + pad;
	var green_slider_x2 = _rect.cont_x + 100 - pad;
	var green_x2 = lerp(green_slider_x1, green_slider_x2, _rect.green / 255);
	var blue_slider_x1 = _rect.cont_x + pad;
	var blue_slider_x2 = _rect.cont_x + 100 - pad;
	var blue_x2  = lerp(blue_slider_x1, blue_slider_x2, _rect.blue  / 255);
    draw_set_colour(_rect._color);
	RTRectangle(_rect.x1,_rect.y1,_rect.x2,_rect.y2,false);
	
	if (_rect.context_open == true)
		{
		draw_set_alpha(0.5)
		draw_rectangle_colour(_rect.cont_x,_rect.cont_y,_rect.cont_x+100,_rect.cont_y+150,c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad,_rect.cont_x+100-pad,_rect.cont_y+bsize,c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+bsize,_rect.cont_x+100-pad,_rect.cont_y+(bsize*2),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*2),_rect.cont_x+100-pad,_rect.cont_y+(bsize*3),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*3),_rect.cont_x+100-pad,_rect.cont_y+(bsize*4),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*4),_rect.cont_x+100-pad,_rect.cont_y+(bsize*5),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*5),_rect.cont_x+100-pad,_rect.cont_y+(bsize*6),c_gray,c_gray,c_gray,c_gray,false);
		draw_set_alpha(1)
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*3),red_x2,_rect.cont_y+(bsize*4),c_red,c_red,c_red,c_red,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*4),green_x2,_rect.cont_y+(bsize*5),c_green,c_green,c_green,c_green,false);
		draw_rectangle_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*5),blue_x2,_rect.cont_y+(bsize*6),c_blue,c_blue,c_blue,c_blue,false);
		draw_text_colour(_rect.cont_x,_rect.cont_y+pad,"Copy Values",c_green,c_green,c_green,c_green,1)
		draw_text_colour(_rect.cont_x+pad,_rect.cont_y+pad+bsize,"Copy Code",c_green,c_green,c_green,c_green,1)
		draw_text_colour(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*2),"Delete",c_red,c_red,c_red,c_red,1)
		}
}

/// @function                 RectanglesInteract;
/// @param {real}  _rect this passes the array to the func
/// @description   This function gets called when using the realtime editor
function RectanglesInteract(_rect)
{
	var handled = false;
	static pad = 2;
	static bsize = 25;
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
	_rect._color = make_color_rgb(_rect.red,_rect.green,_rect.blue);
	var red_slider_x1 = _rect.cont_x + pad;
	var red_slider_x2 = _rect.cont_x + 100 - pad;
	var red_x2 = lerp(red_slider_x1, red_slider_x2, _rect.red / 255);
	var green_slider_x1 = _rect.cont_x + pad;
	var green_slider_x2 = _rect.cont_x + 100 - pad;
	var green_x2 = lerp(green_slider_x1, green_slider_x2, _rect.green / 255);
	var blue_slider_x1 = _rect.cont_x + pad;
	var blue_slider_x2 = _rect.cont_x + 100 - pad;
	var blue_x2  = lerp(blue_slider_x1, blue_slider_x2, _rect.blue  / 255);
	
	if (isInBox(_rect.x1 - 5, _rect.y1 - 5, _rect.x2 + 5, _rect.y1 + 5))//top
        {
			if (mouse_check_button_pressed(mb_left)) {_rect.drag = 1;}
			window_set_cursor(cr_size_ns);
			handled = true;
        }
        else if (isInBox(_rect.x1 - 5, _rect.y2 - 5, _rect.x2 + 5, _rect.y2 + 5))//bottom
        {
            if (mouse_check_button_pressed(mb_left)) {_rect.drag = 2;}
			window_set_cursor(cr_size_ns);
			handled = true;
        }
        else if (isInBox(_rect.x1 - 5, _rect.y1, _rect.x1 + 5, _rect.y2))//left
        {
            if (mouse_check_button_pressed(mb_left)) {_rect.drag = 3;}
			window_set_cursor(cr_size_we);
			handled = true;
        }
        else if (isInBox(_rect.x2 - 5, _rect.y1, _rect.x2 + 5, _rect.y2))//right
        {
            if (mouse_check_button_pressed(mb_left)) {_rect.drag = 4;}
            window_set_cursor(cr_size_we);
			handled = true;
        }
		else if (isInBox(_rect.x1, _rect.y1, _rect.x2, _rect.y2))
		{
		    if (mouse_check_button_pressed(mb_left))
		    {
				if (_rect.context_open == false)
				{
		        _rect.drag = 5;
				_rect.last_mx = mx;
				_rect.last_my = my;
				handled = true;
				}
		    }
			window_set_cursor(cr_size_all);
		}
    if (mouse_check_button(mb_left))
    {
        switch (_rect.drag)
        {
            case 1:
                _rect.y1 = my
            break;

            case 2:
                _rect.y2 = my;
            break;

            case 3:
                _rect.x1 = mx;
            break;

            case 4:
                _rect.x2 = mx;
            break;
			case 5:
				if (_rect.context_open == true && handled == false){_rect.context_open = false}
	            var dx = mx - _rect.last_mx;
	            var dy = my - _rect.last_my;

	            _rect.x1 += dx;
	            _rect.x2 += dx;
	            _rect.y1 += dy;
	            _rect.y2 += dy;

	            _rect.last_mx = mx;
	            _rect.last_my = my;
			break;
        }
    }
    else
    {
        _rect.drag = 0;
        window_set_cursor(cr_default);
    }

	if (isInBox(_rect.x1, _rect.y1, _rect.x2, _rect.y2))
	{
		if (mouse_check_button_pressed(mb_right))
		{
		_rect.cont_x = window_mouse_get_x()
		_rect.cont_y = window_mouse_get_y()
		_rect.context_open = !_rect.context_open
		}
	}	
	if (_rect.context_open == true)
	{
		//copy
		if (isInBox(_rect.cont_x+pad,_rect.cont_y+pad,_rect.cont_x+100-pad,_rect.cont_y+bsize))
		{
			if mouse_check_button_pressed(mb_left)
			{
				clipboard_set_text(string(_rect.x1)+","+string(_rect.y1)+","+string(_rect.x2)+","+string(_rect.y2));
				audio_play_sound(gui_copy,0,0);
			}
		}
		//copy code
		if (isInBox(_rect.cont_x+pad,_rect.cont_y+pad+bsize,_rect.cont_x+100-pad,_rect.cont_y+(bsize*2)))
		{
			if mouse_check_button_pressed(mb_left)
			{
				clipboard_set_text(string(_rect.x1)+","+string(_rect.y1)+","+string(_rect.x2)+","+string(_rect.y2));
				clipboard_set_text("draw_rectangle("+string(_rect.x1)+","+string(_rect.y1)+","+string(_rect.x2)+","+string(_rect.y2)+",false)")
				audio_play_sound(gui_copy,0,0);
			}
		}
		//delete
		if (isInBox(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*2),_rect.cont_x+100-pad,_rect.cont_y+(bsize*3)))
		{
			if mouse_check_button_pressed(mb_left)
			{
				_rect.delete_me = true;
				audio_play_sound(gui_delete,0,0);
			}
		}
		//RGB
		_rect.blue = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*5),_rect.cont_x+100-pad,_rect.cont_y+(bsize*6),_rect.blue);
		_rect.green = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*4),_rect.cont_x+100-pad,_rect.cont_y+(bsize*5),_rect.green);
		_rect.red = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*3),_rect.cont_x+100-pad,_rect.cont_y+(bsize*4),_rect.red);
	}
	return handled;
}





function SpheresInteract(_data)
{
	var handled = false;
	static pad = 2;
	static bsize = 25;
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
	_data._color = make_color_rgb(_data.red,_data.green,_data.blue);
	var red_slider_x1 = _data.cont_x + pad;
	var red_slider_x2 = _data.cont_x + 100 - pad;
	var red_x2 = lerp(red_slider_x1, red_slider_x2, _data.red / 255);
	var green_slider_x1 = _data.cont_x + pad;
	var green_slider_x2 = _data.cont_x + 100 - pad;
	var green_x2 = lerp(green_slider_x1, green_slider_x2, _data.green / 255);
	var blue_slider_x1 = _data.cont_x + pad;
	var blue_slider_x2 = _data.cont_x + 100 - pad;
	var blue_x2  = lerp(blue_slider_x1, blue_slider_x2, _data.blue  / 255);

	if (_rect.context_open == true)
	{
		handled = true;
			//copy
		if (isInBox(_rect.cont_x+pad,_rect.cont_y+pad,_rect.cont_x+100-pad,_rect.cont_y+bsize))
		{
			if mouse_check_button_pressed(mb_left)
			{
				clipboard_set_text(string(_rect.x1)+","+string(_rect.y1)+","+string(_rect.x2)+","+string(_rect.y2));
				audio_play_sound(gui_copy,0,0);
				handled = true;
			}
		}
		//delete
		if (isInBox(_rect.cont_x+pad,_rect.cont_y+pad+bsize,_rect.cont_x+100-pad,_rect.cont_y+(bsize*2)))
		{
			if mouse_check_button_pressed(mb_left)
			{
				_rect.delete_me = true;
				audio_play_sound(gui_delete,0,0);
				handled = true;
			}
		}
		//RGB
		_rect.blue = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*4),_rect.cont_x+100-pad,_rect.cont_y+(bsize*5),_rect.blue);
		_rect.green = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*3),_rect.cont_x+100-pad,_rect.cont_y+(bsize*4),_rect.green);
		_rect.red = GUISlider(_rect.cont_x+pad,_rect.cont_y+pad+(bsize*2),_rect.cont_x+100-pad,_rect.cont_y+(bsize*3),_rect.red);
	}
	return handled;
}




function SpheresDraw(_data)
{
	static pad = 2;
	static bsize = 25;
	_data._color = make_color_rgb(_data.red,_data.green,_data.blue);
	var red_slider_x1 = _data.cont_x + pad;
	var red_slider_x2 = _data.cont_x + 100 - pad;
	var red_x2 = lerp(red_slider_x1, red_slider_x2, _data.red / 255);
	var green_slider_x1 = _data.cont_x + pad;
	var green_slider_x2 = _data.cont_x + 100 - pad;
	var green_x2 = lerp(green_slider_x1, green_slider_x2, _data.green / 255);
	var blue_slider_x1 = _data.cont_x + pad;
	var blue_slider_x2 = _data.cont_x + 100 - pad;
	var blue_x2  = lerp(blue_slider_x1, blue_slider_x2, _data.blue  / 255);
    draw_set_colour(_data._color);
	RTCircle(_data.x1,_data.y1,_data.r,false)
	
	if (_data.context_open == true)
		{
		draw_set_alpha(0.5)
		draw_rectangle_colour(_data.cont_x,_data.cont_y,_data.cont_x+100,_data.cont_y+150,c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad,_data.cont_x+100-pad,_data.cont_y+bsize,c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+bsize,_data.cont_x+100-pad,_data.cont_y+(bsize*2),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+(bsize*2),_data.cont_x+100-pad,_data.cont_y+(bsize*3),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+(bsize*3),_data.cont_x+100-pad,_data.cont_y+(bsize*4),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+(bsize*4),_data.cont_x+100-pad,_data.cont_y+(bsize*5),c_gray,c_gray,c_gray,c_gray,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+(bsize*5),_data.cont_x+100-pad,_data.cont_y+(bsize*6),c_gray,c_gray,c_gray,c_gray,false);
		draw_set_alpha(1)
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+(bsize*3),red_x2,_data.cont_y+(bsize*4),c_red,c_red,c_red,c_red,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+(bsize*4),green_x2,_data.cont_y+(bsize*5),c_green,c_green,c_green,c_green,false);
		draw_rectangle_colour(_data.cont_x+pad,_data.cont_y+pad+(bsize*5),blue_x2,_data.cont_y+(bsize*6),c_blue,c_blue,c_blue,c_blue,false);
		}
}