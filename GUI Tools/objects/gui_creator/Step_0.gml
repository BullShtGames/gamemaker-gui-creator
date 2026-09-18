if (guimode == true)
{
var mouse_handled = false;

if ((rectangles != 0) || (circles != 0) || (sprites !=0))
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
	
	for (var i = array_length(sprites) - 1; i >= 0; i--)
	{
	    if (!mouse_handled)
	    {
	        mouse_handled = SpritesInterat(sprites[i]);
	    }
    if (sprites[i].delete_me)
    {
        array_delete(sprites, i, 1);
    }
	}
	
	for (var i = array_length(circles) - 1; i >= 0; i--)
	{
	    if (!mouse_handled)
	    {
	        mouse_handled = CirclesInteract(circles[i]);
	    }
    if (circles[i].delete_me)
    {
        array_delete(circles, i, 1);
    }
	}
	
}
}