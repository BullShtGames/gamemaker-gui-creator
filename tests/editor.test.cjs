const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');
const root = path.join(__dirname, '..', 'GUI Tools');
const source = name => readFileSync(path.join(root, name), 'utf8');

// These GML functions use JavaScript-compatible syntax. Execute the actual source
// with mocked GameMaker APIs; translate GML's `mod` operator and event `exit`.
// This checks logic, not GameMaker compilation, rendering, or array copy semantics.
function editor(options = {}) {
    const assetIds = options.assetIds ?? [20];
    const validSprites = new Set(options.validSprites ?? assetIds.filter(id => id >= 0));
    const input = { x: -100, y: -100, down: false, pressed: false, right: false, width: 1000, height: 700, escape: false, wheelUp: false, wheelDown: false };
    const draw = { color: 123, alpha: 0.4, font: 88, halign: 1, valign: 2 };
    const calls = [];
    const c = vm.createContext({
        mb_left: 1, mb_right: 2, cr_default: 0, cr_size_all: 1, cr_size_ns: 2, cr_size_we: 3,
        c_white: 0xffffff, c_black: 0, c_gray: 0x808080, c_red: 255, c_green: 65280, c_blue: 16711680,
        Roboto: 10, sprteszt: 20, gui_copy: 30, gui_create: 31, gui_delete: 32, fa_left: 0, fa_top: 0, fa_center: 1,
        asset_sprite: 1, vk_escape: 27, asset_get_ids: type => { assert.equal(type, 1); return assetIds; },
        keyboard_check_pressed: () => input.escape,
        mouse_wheel_up: () => input.wheelUp, mouse_wheel_down: () => input.wheelDown,
        min: Math.min, max: Math.max, abs: Math.abs, floor: Math.floor, ceil: Math.ceil, round: Math.round,
        clamp: (n, low, high) => Math.min(high, Math.max(low, n)),
        point_distance: (x, y, a, b) => Math.hypot(x - a, y - b), string: String,
        device_mouse_x_to_gui: () => input.x, device_mouse_y_to_gui: () => input.y,
        // Deliberately disagree with GUI coordinates to detect accidental window usage.
        window_mouse_get_x: () => input.x * 2, window_mouse_get_y: () => input.y * 2,
        display_get_gui_width: () => input.width, display_get_gui_height: () => input.height,
        mouse_check_button: button => button === 1 ? input.down : input.right,
        mouse_check_button_pressed: button => button === 1 ? input.pressed : input.right,
        sprite_exists: sprite => validSprites.has(sprite), sprite_get_xoffset: () => 32, sprite_get_yoffset: () => 16,
        sprite_get_width: () => options.spriteWidth ?? 64, sprite_get_height: () => options.spriteHeight ?? 48,
        sprite_get_name: sprite => sprite === 20 ? 'sprteszt' : `sprite_${sprite}`,
        string_width: text => text.length * 10,
        is_undefined: value => value === undefined, array_length: a => a.length,
        array_push: (a, value) => a.push(value), array_delete: (a, i, n) => a.splice(i, n),
        make_color_rgb: (r, g, b) => r + g * 256 + b * 65536,
        clipboard_set_text: text => { c.clipboard = text; },
        audio_play_sound: (...args) => calls.push(['sound', ...args]),
        window_set_cursor: cursor => { c.cursor = cursor; },
    });
    for (const key of Object.keys(draw)) {
        c[`draw_get_${key}`] = () => draw[key];
        c[`draw_set_${key}`] = value => { draw[key] = value; };
    }
    for (const name of ['draw_rectangle', 'draw_circle', 'draw_sprite', 'draw_sprite_ext', 'draw_text', 'draw_text_transformed'])
        c[name] = (...args) => calls.push([name, ...args]);
    vm.runInContext(source('scripts/functions/functions.gml').replace(/\bmod\b/g, '%'), c);
    for (const [name, file] of Object.entries({ create: 'Create_0', step: 'Step_0', render: 'Draw_64', toggle: 'KeyPress_115' }))
        vm.runInContext(`function ${name}() {\n${source(`objects/gui_creator/${file}.gml`).replace(/\bexit;/g, 'return;')}\n}`, c);
    c.create();
    c.guimode = true;
    return { c, input, draw, calls, assetIds, validSprites,
        shape(kind, x = 300, y = 200) {
            const s = c.GUIShapeCreate(kind, x, y, 20);
            c[{ rectangle: 'rectangles', circle: 'circles', sprite: 'sprites' }[kind]].push(s);
            return s;
        },
        frame(x, y, down = false, pressed = false, right = false) {
            Object.assign(input, { x, y, down, pressed, right });
            c.step();
        },
    };
}

test('rectangle hit tests use GUI coordinates and return a boolean on misses', () => {
    const { c, input } = editor();
    Object.assign(input, { x: 15, y: 15 });
    assert.equal(c.isInBox(10, 10, 20, 20), true);
    assert.equal(c.isInBox(20, 20, 10, 10), true);
    input.x = 21;
    assert.equal(c.isInBox(10, 10, 20, 20), false);
});

test('creation runs in Step once and uses current GUI dimensions', () => {
    const e = editor();
    e.input.width = 1600;
    e.input.height = 900;
    e.frame(20, 20, true, true);
    assert.equal(e.c.rectangles.length, 1);
    assert.equal(e.c.rectangles[0].x1, 800);
    assert.equal(e.c.rectangles[0].y1, 450);
    e.c.render(); e.c.render();
    assert.equal(e.c.rectangles.length, 1);
});

test('topmost circle owns input ahead of rectangles and sprites', () => {
    const e = editor();
    const sprite = e.shape('sprite');
    const rect = e.shape('rectangle');
    const circle = e.shape('circle', 320, 220);
    circle.r = 40;
    e.frame(320, 220, true, true);
    assert.equal(e.c.active_shape, circle);
    e.frame(600, 500, true);
    assert.equal(circle.x1, 600);
    assert.equal(rect.x1, 300);
    assert.equal(sprite.x1, 300);
});

test('newest rectangle gets input and dragging keeps ownership outside its bounds', () => {
    const e = editor();
    const back = e.shape('rectangle');
    const front = e.shape('rectangle');
    e.frame(350, 250, true, true);
    assert.equal(e.c.active_shape, front);
    e.frame(800, 600, true);
    assert.equal(front.x1, 750);
    assert.equal(back.x1, 300);
    e.frame(850, 650);
    assert.equal(front.drag, 0);
    assert.equal(e.c.active_shape, undefined);
});

test('rectangle resize cannot invert its bounds', () => {
    const e = editor();
    const s = e.shape('rectangle');
    e.frame(300, 250, true, true);
    e.frame(600, 250, true);
    assert.equal(s.x1, s.x2 - 5);
    e.frame(600, 250);
    e.frame(s.x1 + 2, s.y1, true, true);
    e.frame(600, 900, true);
    assert.equal(s.y1, s.y2 - 5);
});

test('a minimum-radius circle can move by its center and resize by its edge', () => {
    const e = editor();
    const s = e.shape('circle');
    e.frame(300, 200, true, true);
    e.frame(350, 250, true);
    assert.equal(s.x1, 350);
    assert.equal(s.r, 5);
    e.frame(350, 250);
    e.frame(355, 250, true, true);
    e.frame(400, 250, true);
    assert.equal(s.r, 50);
});

test('a minimum-size rectangle retains a movable interior', () => {
    const e = editor();
    const s = e.shape('rectangle');
    s.x2 = s.x1 + 5;
    s.y2 = s.y1 + 5;
    e.frame(302.5, 202.5, true, true);
    e.frame(402.5, 302.5, true);
    assert.equal(s.drag, 5);
    assert.equal(s.x1, 400);
    assert.equal(s.y1, 300);
    assert.equal(s.x2, 405);
    assert.equal(s.y2, 305);
});

test('sprite hit tests account for the sprite origin and reject invalid assets', () => {
    const e = editor();
    const s = e.shape('sprite');
    Object.assign(e.input, { x: 270, y: 185 });
    assert.equal(e.c.GUIShapeHit(s), true);
    e.input.x = 340;
    assert.equal(e.c.GUIShapeHit(s), false);
    s.sprite = -1;
    assert.equal(e.c.GUIShapeHit(s), false);
});

test('menus use GUI coordinates and clamp to the viewport', () => {
    const e = editor();
    const s = e.shape('rectangle', 900, 600);
    e.frame(950, 650, false, false, true);
    assert.equal(e.c.context_shape, s);
    assert.equal(s.cont_x, 900);
    assert.equal(s.cont_y, 550);
});

test('menu over a shape copies code without dragging or deleting the shape', () => {
    const e = editor();
    const s = e.shape('rectangle');
    s.red = 17; s.green = 34; s.blue = 51;
    e.frame(320, 220, false, false, true);
    e.frame(340, 250, true, true);
    assert.equal(s.drag, 0);
    assert.equal(e.c.active_shape, undefined);
    assert.equal(e.c.rectangles.length, 1);
    assert.match(e.c.clipboard, /make_color_rgb\(17,34,51\)/);
    assert.match(e.c.clipboard, /draw_rectangle\(300,200,400,300,false\);/);
});

test('menu actions and sliders work for every shape type', () => {
    for (const kind of ['rectangle', 'circle', 'sprite']) {
        const e = editor();
        const s = e.shape(kind);
        e.frame(300, 200, false, false, true);
        e.frame(310, 210, true, true);
        assert.equal(e.c.clipboard, e.c.GUIShapeValues(s));
        e.frame(310, 210);
        e.frame(350, 290, true, true);
        assert.equal(s.red, 128);
        assert.equal(s.green, 255);
        assert.equal(s.blue, 255);
        e.frame(800, 500, true);
        assert.equal(s.red, 255);
        e.frame(800, 500);
        e.frame(310, 260, true, true);
        assert.equal(e.c[{ rectangle: 'rectangles', circle: 'circles', sprite: 'sprites' }[kind]].length, 0);
        assert.equal(e.c.context_shape, undefined);
    }
});

test('slider row boundaries update only one channel', () => {
    const e = editor();
    const s = e.shape('rectangle');
    e.frame(300, 200, false, false, true);
    e.frame(350, 300, true, true);
    assert.equal(s.red, 255);
    assert.equal(s.green, 128);
    assert.equal(s.blue, 255);
});

test('toolbar has input priority over shapes behind it', () => {
    const e = editor();
    const s = e.shape('rectangle', 0, 0);
    e.frame(20, 20, true, true);
    assert.equal(e.c.rectangles.length, 2);
    assert.equal(s.drag, 0);
});

test('F4 cancels drag and slider capture and hides menus', () => {
    const e = editor();
    const s = e.shape('rectangle');
    e.frame(350, 250, true, true);
    e.c.toggle();
    assert.equal(s.drag, 0);
    assert.equal(e.c.active_shape, undefined);
    e.c.toggle();
    e.frame(350, 250, false, false, true);
    e.frame(360, 340, true, true);
    assert.equal(s.slider, 0);
    e.c.toggle();
    assert.equal(s.slider, -1);
    assert.equal(e.c.context_shape, undefined);
    assert.equal(e.c.cursor, e.c.cr_default);
});

test('Draw GUI restores shared state, draws menus last, and hides editor UI when disabled', () => {
    const e = editor();
    e.shape('rectangle');
    const sprite = e.shape('sprite');
    sprite.red = 10;
    e.frame(350, 250, false, false, true);
    const saved = { ...e.draw };
    e.c.render();
    assert.deepEqual(e.draw, saved);
    const spriteCall = e.calls.find(call => call[0] === 'draw_sprite_ext');
    assert.equal(spriteCall[8], e.c.make_color_rgb(10, 255, 255));
    assert.equal(e.calls.at(-1)[0], 'draw_rectangle'); // Blue menu slider is last.
    e.c.toggle();
    e.calls.length = 0;
    e.c.render();
    assert.deepEqual(e.draw, saved);
    assert.equal(e.calls.length, 2); // Shapes remain visible in preview mode.
});

test('sprite and circle exports reproduce geometry and color', () => {
    const e = editor();
    const sprite = e.shape('sprite');
    assert.equal(e.c.GUIShapeCode(sprite), 'draw_sprite_ext(sprteszt,0,300,200,1,1,0,make_color_rgb(255,255,255),1);');
    const circle = e.shape('circle');
    assert.match(e.c.GUIShapeCode(circle), /draw_circle\(300,200,5,false\);/);
});

test('zero-width standalone sliders leave their value unchanged', () => {
    const e = editor();
    Object.assign(e.input, { x: 10, y: 15, down: true });
    assert.equal(e.c.GUISlider(10, 10, 10, 20, 100), 100);
});

function openPicker(e) {
    e.frame(450, 20, true, true);
    assert.equal(e.c.sprite_picker.open, true);
    assert.equal(e.c.sprites.length, 0);
    e.frame(450, 20);
    return e.c.GUISpritePickerLayout(e.c.sprite_picker);
}

function clickCell(e, layout, cell) {
    const x = layout.grid_x + (cell % layout.columns + 0.5) * layout.cell_width;
    const y = layout.grid_y + (Math.floor(cell / layout.columns) + 0.5) * layout.cell_height;
    e.frame(x, y, true, true);
}

test('Add Sprite discovers sparse sprite IDs, filters invalid assets, and adds only the clicked sprite', () => {
    const e = editor({ assetIds: [0, 20, 999, -1] });
    const layout = openPicker(e);
    assert.deepEqual(Array.from(e.c.sprite_picker.items), [0, 20, 999]);
    clickCell(e, layout, 2);
    assert.equal(e.c.sprite_picker.open, false);
    assert.equal(e.c.sprites.length, 1);
    assert.equal(e.c.sprites[0].sprite, 999);
    assert.equal(e.c.sprites[0].x1, e.input.width / 2);
    assert.equal(e.c.sprites[0].y1, e.input.height / 2);
    assert.equal(e.c.sprites[0].drag, 0);
    e.c.render(); e.c.render();
    assert.equal(e.c.sprites.length, 1);
});

test('sprite asset zero is selectable and discovery refreshes on reopening', () => {
    const e = editor({ assetIds: [0] });
    let layout = openPicker(e);
    clickCell(e, layout, 0);
    assert.equal(e.c.sprites[0].sprite, 0);
    e.assetIds.push(1000);
    e.validSprites.add(1000);
    e.frame(450, 20, true, true);
    layout = e.c.GUISpritePickerLayout(e.c.sprite_picker);
    assert.deepEqual(Array.from(e.c.sprite_picker.items), [0, 1000]);
    clickCell(e, layout, 1);
    assert.equal(e.c.sprites[1].sprite, 1000);
});

test('picker paging reaches later sprites using buttons and the wheel', () => {
    const e = editor({ assetIds: Array.from({ length: 50 }, (_, i) => i * 100) });
    const layout = openPicker(e);
    const bottom = layout.y + layout.height;
    const nextX = layout.x + layout.width - 40;
    e.frame(nextX, bottom - 20, true, true);
    assert.equal(e.c.sprite_picker.page, 1);
    e.input.wheelUp = true;
    e.frame(nextX, bottom - 20);
    assert.equal(e.c.sprite_picker.page, 0);
    e.input.wheelUp = false;
    e.input.wheelDown = true;
    e.frame(nextX, bottom - 20);
    assert.equal(e.c.sprite_picker.page, 1);
    e.input.wheelDown = false;
    clickCell(e, layout, 1);
    assert.equal(e.c.sprites[0].sprite, (layout.capacity + 1) * 100);
});

test('picker consumes clicks over shapes, toolbar, and empty cells', () => {
    const e = editor();
    const s = e.shape('rectangle');
    const layout = openPicker(e);
    clickCell(e, layout, 1); // Only cell zero is populated.
    assert.equal(e.c.sprite_picker.open, true);
    assert.equal(e.c.sprites.length, 0);
    assert.equal(s.drag, 0);
    e.frame(20, 20, true, true); // Outside closes without activating toolbar.
    assert.equal(e.c.sprite_picker.open, false);
    assert.equal(e.c.rectangles.length, 1);
});

test('picker supports empty projects and dismissal with X, Escape, and F4', () => {
    for (const action of ['close', 'escape', 'toggle']) {
        const e = editor({ assetIds: [] });
        const layout = openPicker(e);
        e.c.render();
        assert.ok(e.calls.some(call => call[0] === 'draw_text' && call[3] === 'No sprites found.'));
        if (action === 'close') e.frame(layout.x + layout.width - 20, layout.y + 20, true, true);
        if (action === 'escape') { e.input.escape = true; e.frame(300, 200); }
        if (action === 'toggle') e.c.toggle();
        assert.equal(e.c.sprite_picker.open, false);
        assert.equal(e.c.sprites.length, 0);
    }
});

test('page clamps after GUI resizing and empty tail cells do not add sprites', () => {
    const e = editor({ assetIds: Array.from({ length: 25 }, (_, i) => i) });
    e.input.width = 400;
    e.input.height = 400;
    // Open directly because the Add Sprite button is outside this narrow GUI.
    e.c.GUISpritePickerOpen(e.c.sprite_picker);
    e.c.sprite_picker.page = 100;
    e.frame(-1, -1);
    const narrow = e.c.GUISpritePickerLayout(e.c.sprite_picker);
    assert.equal(e.c.sprite_picker.page, narrow.pages - 1);
    e.input.width = 1000;
    e.input.height = 700;
    e.frame(-1, -1);
    const wide = e.c.GUISpritePickerLayout(e.c.sprite_picker);
    assert.equal(e.c.sprite_picker.page, wide.pages - 1);
    clickCell(e, wide, wide.capacity - 1);
    assert.equal(e.c.sprite_picker.open, true);
    assert.equal(e.c.sprites.length, 0);
});

test('preview scales large sprites into their cells with correct origin and restores drawing state', () => {
    const e = editor({ spriteWidth: 1024, spriteHeight: 512 });
    const layout = openPicker(e);
    const saved = { ...e.draw };
    e.c.render();
    const preview = e.calls.find(call => call[0] === 'draw_sprite_ext');
    const [, , frame, x, y, sx, sy] = preview;
    assert.equal(frame, 0);
    assert.equal(sx, sy);
    assert.ok(sx < 1);
    assert.ok(x - 32 * sx >= layout.grid_x);
    assert.ok(x - 32 * sx + 1024 * sx <= layout.grid_x + layout.cell_width);
    assert.ok(y - 16 * sy >= layout.grid_y);
    assert.ok(y - 16 * sy + 512 * sy <= layout.grid_y + layout.cell_height - 24);
    assert.deepEqual(e.draw, saved);
});

test('sprites removed while picker is open cannot be added', () => {
    const e = editor();
    const layout = openPicker(e);
    e.validSprites.delete(20);
    clickCell(e, layout, 0);
    assert.equal(e.c.sprites.length, 0);
    assert.equal(e.c.sprite_picker.open, true);
});
