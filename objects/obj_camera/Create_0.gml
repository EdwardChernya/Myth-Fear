/// @description Insert description here
// You can write your code in this editor

default_zoom = 4;
min_zoom = 2;
zoom = 2;
smooth_zoom = 4;

width = 1;
height = 1;
world_width = width/zoom;
world_height = height/zoom;

is_minimalUI = false;

static_drawn = 0;
dynamic_drawn = 0;


target = undefined;
is_dragging = false;
drag_start = new Vector2();

mobileoffset = 0;
if (os_browser == browser_safari_mobile) {
	mobileoffset = 96;
}
