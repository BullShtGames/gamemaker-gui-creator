if (guimode == true)
{
var mouse_handled = false;

if (rectangles != 0)
{
	for (var i = array_length(rectangles) - 1; i >= 0; i--)
	{
	    if (!mouse_handled)
	    {
	        mouse_handled = RectanglesInteract(rectangles[i]);
	    }
    if (rectangles[i].delete_me)
    {
        array_delete(rectangles, i, 1);
    }
	}
}
}