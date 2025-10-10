/// @description Insert description here
// You can write your code in this editor

draw_set_font(fnt_1);
draw_set_color(c_lime);


draw_set_valign(fa_top);
draw_set_halign(fa_middle);
if (DEV) draw_text(width/2, 0, PLAYER.character_main.state);


draw_set_halign(fa_left);


if (DEV) {
	draw_text(64, 0, $"{width} | {height}");
	draw_text(64, 24, "developer");
}

if (is_fullscreen) {
	draw_sprite_ext(s_fs, 0, 16, 16, 1, 1, 0, c_lime, 1);
} else {
	draw_sprite_ext(s_fs, 1, 16, 16, 1, 1, 0, c_lime, 1);
}


draw_set_halign(fa_right);
draw_text(browser_width, 0, $"{fps}");

draw_set_valign(fa_bottom);
draw_set_color(c_dkgray);
draw_text(browser_width, browser_height, $"{VERSION}");
draw_set_color(c_lime);
if (DEV) {
	var cell = MAP.collision_grid_cell_size;
	draw_text(MOUSE.x, MOUSE.y, $"{to_grid(mouse_x, cell)} {to_grid(mouse_y, cell)}");
	draw_text(MOUSE.x, MOUSE.y-24, $"{MAP.collision_grid[to_grid(mouse_x, cell)][to_grid(mouse_y, cell)]}");
	draw_text(MOUSE.x, MOUSE.y-48, $"{MAP.fog_grid[to_grid(mouse_x, cell)][to_grid(mouse_y, cell)].type}");
}