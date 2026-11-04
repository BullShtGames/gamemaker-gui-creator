if (!guimode) exit;

window_set_cursor(cr_default);
// The picker is modal: selection, navigation, and dismissal cannot edit shapes.
if (sprite_picker.open)
{
    var selected_sprite = GUISpritePickerInteract(sprite_picker);
    if (!is_undefined(selected_sprite) && sprite_exists(selected_sprite))
    {
        var selected_shape = GUIShapeCreate("sprite", display_get_gui_width() / 2, display_get_gui_height() / 2, selected_sprite);
        array_push(sprites, selected_shape);
        audio_play_sound(gui_create, 0, false);
    }
    exit;
}
var mouse_handled = false;

// Keep ownership while dragging, even over another shape, menu, or toolbar.
if (!is_undefined(active_shape))
{
    GUIShapeInteract(active_shape);
    mouse_handled = true;
    if (!mouse_check_button(mb_left)) active_shape = undefined;
}

if (!mouse_handled && !is_undefined(context_shape))
{
    if (GUIContextHit(context_shape) || context_shape.slider >= 0)
    {
        GUIContextInteract(context_shape);
        mouse_handled = true;
    }
    else if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right))
    {
        context_shape.context_open = false;
        context_shape = undefined;
    }
}

// Creation belongs in Step; Draw GUI may run more than once per update.
if (!mouse_handled && isInBox(0, 0, display_get_gui_width(), 80))
{
    mouse_handled = true;
    if (mouse_check_button_pressed(mb_left))
    {
        var kind = "";
        if (isInBox(12, 6, 200, 51)) kind = "rectangle";
        else if (isInBox(212, 6, 400, 51)) kind = "circle";
        else if (isInBox(412, 6, 600, 51)) GUISpritePickerOpen(sprite_picker);
        if (kind != "")
        {
            var data = GUIShapeCreate(kind, display_get_gui_width() / 2, display_get_gui_height() / 2, -1);
            switch (kind)
            {
                case "rectangle": array_push(rectangles, data); break;
                case "circle": array_push(circles, data); break;
            }
            audio_play_sound(gui_create, 0, false);
        }
    }
}

// Reverse the drawing order so the visibly topmost shape receives input.
var groups = [circles, rectangles, sprites];
for (var group = 0; group < array_length(groups); group++)
{
    var shapes = groups[group];
    for (var i = array_length(shapes) - 1; i >= 0; i--)
    {
        var shape = shapes[i];
        if (!mouse_handled && GUIShapeInteract(shape))
        {
            mouse_handled = true;
            if (shape.drag != 0) active_shape = shape;
            if (mouse_check_button_pressed(mb_right))
            {
                shape.cont_x = clamp(device_mouse_x_to_gui(0), 0, max(0, display_get_gui_width() - 100));
                shape.cont_y = clamp(device_mouse_y_to_gui(0), 0, max(0, display_get_gui_height() - 150));
                shape.context_open = true;
                context_shape = shape;
            }
        }
    }
}

// Delete from the owning arrays, rather than copies in the groups array.
for (var i = array_length(rectangles) - 1; i >= 0; i--)
    if (rectangles[i].delete_me) array_delete(rectangles, i, 1);
for (var i = array_length(circles) - 1; i >= 0; i--)
    if (circles[i].delete_me) array_delete(circles, i, 1);
for (var i = array_length(sprites) - 1; i >= 0; i--)
    if (sprites[i].delete_me) array_delete(sprites, i, 1);
if (!is_undefined(context_shape) && context_shape.delete_me) context_shape = undefined;
