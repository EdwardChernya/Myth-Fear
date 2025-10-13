/// @description Insert description here
// You can write your code in this editor

width = display_get_width();
height = display_get_height();
world_width = width/zoom;
world_height = height/zoom;

if (window_get_width() != width or window_get_height() != height) {
	window_set_size(width, height);
	var ssize = max(width, height);
	surface_resize(application_surface, ssize, ssize);
	window_center();
}

camera_set_view_size(view_camera[0], world_width, world_height);

// target is always player for now
if (!instance_exists(PLAYER) || room != Room1) exit;

if (target == PLAYER) {
	x += (PLAYER.position.x-x)*.1;
	y += (PLAYER.position.y-y)*.1;
} else if (target == MOUSE) {
	if (mouse_check_button_pressed(mb_right)) {
		is_dragging = true;
		drag_start.Set({x:x, y:y});
		drag_start.xmouse = MOUSE.x;
		drag_start.ymouse = MOUSE.y;
	}
	if (is_dragging) {
		if (mouse_check_button_released(mb_right)) is_dragging = false;
		x = drag_start.x+drag_start.xmouse/zoom-MOUSE.x/zoom;
		y = drag_start.y+drag_start.ymouse/zoom-MOUSE.y/zoom;
	}
} else if (target != undefined) {
	x += (target.position.x-x)*.1;
	y += (target.position.y-y)*.1;
}

// keep within room bounds and not show outside area
x = floor(min(max(world_width/2, x), room_width-world_width/2));
y = floor(min(max(world_height/2, y), room_height-world_height/2));
	
if (mouse_wheel_down()) smooth_zoom -= 1;
if (mouse_wheel_up()) smooth_zoom += smooth_zoom == .5 ? .5 : 1;
var wide_res = max(width, height);
var minimum_zoom = max(2, ceil(wide_res/room_width));
min_zoom = DEV ? 0.5 : minimum_zoom;
smooth_zoom = clamp(smooth_zoom, min_zoom, 10);
zoom += (smooth_zoom-zoom)*.1;
