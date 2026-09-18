if (guimode == true)
{
draw_set_font(Roboto)
draw_set_alpha(0.5)
draw_rectangle_colour(0,0,window_get_width(),80,c_black,c_black,c_black,c_black,false)
draw_text_colour(12,6,"Add Rectangle",c_green,c_green,c_green,c_green,1)
draw_text_colour(212,6,"Add Circle",c_green,c_green,c_green,c_green,1)
draw_text_colour(412,6,"Add Sprite",c_green,c_green,c_green,c_green,1)
draw_rectangle_colour(12,6,200,51,c_gray,c_gray,c_gray,c_gray,false)
draw_rectangle_colour(212,6,400,51,c_gray,c_gray,c_gray,c_gray,false)
draw_rectangle_colour(412,6,600,51,c_gray,c_gray,c_gray,c_gray,false)
if isInBox(12,6,200,51)
{
	draw_rectangle_colour(12,6,200,51,c_white,c_white,c_white,c_white,false)
	if mouse_check_button_pressed(mb_left)
	{
			var rect = {
			    x1: winhalfW,
			    y1: winhalfH,
			    x2: winhalfW+100,
			    y2: winhalfH+100,
			    _color: c_white,
			    drag: 0,
				last_mx: 0,
				last_my: 0,
				context_open: false,
				cont_x: 0,
				cont_y: 0,
				red: 255,
				green: 255,
				blue: 255,
				delete_me: false
			};
			audio_play_sound(gui_create,0,0)
			array_push(rectangles, rect);
	}
}
draw_set_alpha(1)

if isInBox(212,6,400,51)
{
	draw_rectangle_colour(212,6,400,51,c_white,c_white,c_white,c_white,false)
	if mouse_check_button_pressed(mb_left)
	{
			var data = {
			    x1: winhalfW,
			    y1: winhalfH,
				r: 5,
			    _color: c_white,
			    drag: 0,
				last_mx: 0,
				last_my: 0,
				context_open: false,
				cont_x: 0,
				cont_y: 0,
				red: 255,
				green: 255,
				blue: 255,
				delete_me: false
			};
			audio_play_sound(gui_create,0,0)
			array_push(circles, data);
	}
}

if isInBox(412,6,600,51)
{
	draw_rectangle_colour(412,6,600,51,c_white,c_white,c_white,c_white,false)
	if mouse_check_button_pressed(mb_left)
	{
			var data = {
			    x1: winhalfW,
			    y1: winhalfH,
				sprite: spritename,
			    sub: 0,
			    drag: 0,
				last_mx: 0,
				last_my: 0,
				context_open: false,
				cont_x: 0,
				cont_y: 0,
				red: 255,
				green: 255,
				blue: 255,
				delete_me: false
			};
			audio_play_sound(gui_create,0,0)
			array_push(sprites, data);
		}
	}
}
if (sprites != 0)
{
	for (var i = 0; i < array_length(sprites); i++)
	{
	    SpritesDraw(sprites[i])
	}
}

if (rectangles != 0)
{
	for (var i = 0; i < array_length(rectangles); i++)
	{
	    RectanglesDraw(rectangles[i])
	}
}
if (circles != 0)
{
	for (var i = 0; i < array_length(circles); i++)
	{
	    CirclesDraw(circles[i])
	}
}