/// @description Insert description here
// You can write your code in this editor


MOUSE.x = device_mouse_raw_x(0);
MOUSE.y = device_mouse_raw_y(0);

DEBUG.update();

if (room == rm_main_menu) {
	
	if (point_in_rectangle(MOUSE.x, MOUSE.y, CAMERA.width/2-50, CAMERA.height/2-25, CAMERA.width/2+50, CAMERA.height/2+25)) {
		if (_touch_down()) {
			DEBUG.add("generating nodes", c_olive);
			MAP.size = 64;
			MAP.collision_grid_size = MAP.size*MAP.collision_scale;
			MAP.collision_grid_cell_size = TILE/MAP.collision_scale;
			init_map();
		}
		button_text = "> generate map >";
	} else {
		button_text = "generate map";
	}
	
}

if (DEV and room == Room1) {
	if (keyboard_check_pressed(ord("R"))) room_goto(rm_main_menu);
}