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

if (instance_exists(PLAYER) and room == Room1) {
	x += (PLAYER.position.x-x)*.1;
	y += (PLAYER.position.y-y)*.1;
	x = floor(max(world_width/2, min(room_width-world_width/2, x)));
	y = floor(max(world_height/2, min(room_height-world_height/2, y)));
	
	if (mouse_wheel_down()) smooth_zoom -= 1;
	if (mouse_wheel_up()) smooth_zoom += 1;
	var wide_res = max(width, height);
	var minimum_zoom = max(2, ceil(wide_res/room_width));
	min_zoom = DEV ? 0.5 : minimum_zoom;
	smooth_zoom = clamp(smooth_zoom, min_zoom, 10);
	zoom += (smooth_zoom-zoom)*.1;
}