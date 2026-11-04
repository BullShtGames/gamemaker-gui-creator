// Restore shared drawing state so importing the editor does not affect the game.
var saved_color = draw_get_color();
var saved_alpha = draw_get_alpha();
var saved_font = draw_get_font();
var saved_halign = draw_get_halign();
var saved_valign = draw_get_valign();
draw_set_alpha(1);

for (var i = 0; i < array_length(sprites); i++) SpritesDraw(sprites[i]);
for (var i = 0; i < array_length(rectangles); i++) RectanglesDraw(rectangles[i]);
for (var i = 0; i < array_length(circles); i++) CirclesDraw(circles[i]);

if (guimode)
{
    draw_set_font(Roboto);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(0, 0, display_get_gui_width(), 80, false);
    draw_set_alpha(1);
    var labels = ["Add Rectangle", "Add Circle", "Add Sprite"];
    for (var button = 0; button < 3; button++)
    {
        var bx = 12 + button * 200;
        draw_set_color(c_gray);
        if (isInBox(bx, 6, bx + 188, 51)) draw_set_color(c_white);
        draw_rectangle(bx, 6, bx + 188, 51, false);
        draw_set_color(c_green);
        draw_text(bx, 6, labels[button]);
    }
    // Menus are drawn last and receive input first.
    if (!is_undefined(context_shape)) GUIContextDraw(context_shape);
    if (sprite_picker.open) GUISpritePickerDraw(sprite_picker);
}

draw_set_color(saved_color);
draw_set_alpha(saved_alpha);
draw_set_font(saved_font);
draw_set_halign(saved_halign);
draw_set_valign(saved_valign);
