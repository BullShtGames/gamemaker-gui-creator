guimode = !guimode;
if (!is_undefined(active_shape)) active_shape.drag = 0;
if (!is_undefined(context_shape))
{
    context_shape.context_open = false;
    context_shape.slider = -1;
}
active_shape = undefined;
context_shape = undefined;
window_set_cursor(cr_default);
