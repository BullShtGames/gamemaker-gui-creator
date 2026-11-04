
# Gamemaker GUI Creator

This is a Work In Progress In-game GUI creator for Gamemaker. The main goal is that you'll import a yymps to your game and you can design your GUI-s while in-game, so you wont't have to guess your dimesions, placements

## Features/planned features

- Rectangle Creator ✅
- Circle creator ✅
- Sprite picker grid with previews, names, and paging ✅
- Dynamic positions for all resolutions(future)
- Maybe a whole GUI system with sliders buttons etc
- More refined interface(once everything works intended)


## Installation

From the releases tab, download the .yymps file and import to your project using the project tool
Add the object named gui_creator to your room, once you started your game press F4 to create either a rectangle or a circle.
You can create rectangles and circles, move them around freely, resize them, change the color and copy either the position values or the complete code
Use the right click on the circle or rectangle to bring up a context menu

## Working from source

Open `GUI Tools/GUI Tools.yyp` in GameMaker and run `Room1`. The checked-in
`.yymps` files are older release snapshots; export a new local package from the
project to include the current source fixes when importing into another game.

F4 switches editing on or off. Shapes stay visible when editing is off. The
toolbar adds rectangles and circles. **Add Sprite** opens a grid of all sprite
assets in the running project. Click a preview to add that sprite at the GUI
center. Use **Prev**, **Next**, or the mouse wheel to browse pages; close the
picker with **X**, Escape, F4, or a click outside it. Drag a shape's interior to
move it, or a rectangle edge or circle rim to resize it. Right-click a shape to copy its values, copy drawing
code including its color, delete it, or adjust its RGB sliders. Click outside
the menu to close it. Sprite placement supports moving and tinting; sprite
scaling remains unfinished.

The picker refreshes the asset list whenever it opens. Keep **Remove unused
assets** disabled in GameMaker's Main options when importing this editor into
another project, so sprites referenced only through the picker are available in
the build. This source project already disables that option.

## Validation

Run `node tests/editor.test.cjs` with Node.js 18 or newer. These regression tests
execute the interaction source with mocked GameMaker APIs. They cover input
priority, drag capture, GUI coordinates, resize limits, menus, color exports,
sprite discovery and picker navigation, and drawing-state restoration. They do
not replace compilation and visual testing in GameMaker.

In GameMaker, also check the following:

- Set a GUI size different from the window size with `display_set_gui_size`,
  then create, move, resize, and right-click each shape type.
- Overlap shapes, open a menu over another shape, and drag across the toolbar.
  Only the topmost shape or menu should react.
- Resize a rectangle past its opposite edge and move a newly created small
  circle by its center. Neither should become uneditable.
- Paste copied code into a Draw GUI event and compare geometry and color.
- Toggle F4 during a drag or slider adjustment. Editing should stop immediately,
  while the created shapes remain visible.
- Add multiple sprites in the IDE, including one with a centered origin and one
  larger than its preview cell. Open Add Sprite, browse pages, and select them.
  Each should appear once as a movable GUI element, with no input passed through
  the picker to the shapes underneath it.

    
