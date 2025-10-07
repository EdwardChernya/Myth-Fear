/// @description Insert description here
// You can write your code in this editor

#macro VERSION "01a002dev"
global.dev = true;
#macro DEV global.dev
global.gamespeed = 1;
game_set_speed(60, gamespeed_fps);

instance_create_layer(0, 0, "Instances", obj_player);
instance_create_layer(0, 0, "Instances", obj_camera);
instance_create_layer(0, 0, "Map", obj_map);

#macro PLAYER obj_player
#macro MAP obj_map
#macro CAMERA obj_camera
#macro TILE 64

global.mouse_input = {
	x : 1,
	y : 1,
};
#macro MOUSE global.mouse_input


if (os_browser != browser_not_a_browser && !instance_exists(obj_HTML_FS)) { instance_create_depth(x,y,depth,obj_HTML_FS); }
button_text = "generate map";

global.debug_text = new floating_text_manager();
#macro DEBUG global.debug_text


DEBUG.add("game started", c_olive);