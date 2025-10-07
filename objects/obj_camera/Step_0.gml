/// @description Insert description here
// You can write your code in this editor

width = display_get_width();
height = display_get_height();

if (window_get_width() != width or window_get_height() != height) {
	window_set_size(width, height);
	var ssize = max(width, height);
	surface_resize(application_surface, ssize, ssize);
	window_center();
}

camera_set_view_size(view_camera[0], width/zoom, height/zoom);

if (instance_exists(PLAYER) and room == Room1) {
	x += (PLAYER.position.x-x)*.1;
	y += (PLAYER.position.y-y)*.1;
	
	if (mouse_wheel_down()) zoom -= 1;
	if (mouse_wheel_up()) zoom += 1;
	zoom = clamp(zoom, 0.5, 10);
}