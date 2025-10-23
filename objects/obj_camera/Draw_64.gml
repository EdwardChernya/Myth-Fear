/// @description Insert description here
// You can write your code in this editor

draw_set_font(fnt_1);

draw_set_color(c_dkgray);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(browser_width - mobileoffset, browser_height, $"{VERSION}");
draw_set_color(c_lime);
draw_set_valign(fa_top);
draw_text(browser_width - (orientation == "horizontal" ? mobileoffset : 0), orientation == "horizontal" ? 0 : mobileoffset, $"{fps}");


if (DEV and room == Room1) {
	draw_set_valign(fa_bottom);
	var cell = MAP.collision_grid_cell_size;
	var grid_x = to_grid(mouse_x, cell), grid_y = to_grid(mouse_y, cell);
	draw_text(MOUSE.x, MOUSE.y, $"{to_grid(mouse_x, cell)} {to_grid(mouse_y, cell)}");
	draw_text(MOUSE.x, MOUSE.y-24, $"{MAP.collision_grid[to_grid(mouse_x, cell)][to_grid(mouse_y, cell)]}");
	draw_text(MOUSE.x, MOUSE.y-48, $"{MAP.fog_grid[to_grid(mouse_x, cell)][to_grid(mouse_y, cell)]}");
	var asset = MAP.assets_grid[to_grid(mouse_x, cell)][to_grid(mouse_y, cell)];
	if (asset != undefined) draw_text(MOUSE.x, MOUSE.y-72, $"{asset.type}");
	var asset = MAP.static_assets[to_grid(mouse_x, cell)][to_grid(mouse_y, cell)];
	if (asset != undefined) draw_text(MOUSE.x, MOUSE.y-96, $"{asset.type}");
	var p1 = to_screen(grid_x*cell, grid_y*cell);
	var p2 = to_screen(grid_x*cell+cell, grid_y*cell+cell)
	if (zoom >= min_zoom) draw_rectangle(p1.x, p1.y, p2.x-1, p2.y-1, true);
	
	draw_set_valign(fa_top);
	draw_set_halign(fa_middle);
	draw_text(floor(width/2), 0, $"{PLAYER.state.name}");
	draw_text(floor(width/2), 24, $"{PLAYER.state_buffer == undefined ? "none" : PLAYER.state_buffer.name}");

	draw_set_halign(fa_left);
	draw_text(orientation == "horizontal" ? mobileoffset : 0, orientation == "horizontal" ? 0 : mobileoffset, $"{width} | {height}");
	draw_text(orientation == "horizontal" ? mobileoffset : 0, orientation == "horizontal" ? 24 : mobileoffset + 24, "developer");
	
	draw_set_halign(fa_right);
	draw_text(CAMERA.width, 200, MAP.map_name);
	draw_text(CAMERA.width, 224, $"dynamic {dynamic_drawn} static {static_drawn}");
}