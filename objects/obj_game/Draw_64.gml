/// @description Insert description here
// You can write your code in this editor


draw_set_font(fnt_1);
draw_set_color(c_lime);
draw_set_halign(fa_center);
draw_set_valign(fa_top);

if (room == rm_main_menu) {
	draw_text(CAMERA.width/2, CAMERA.height/2, button_text);
}

if (DEV) {
	DEBUG.draw();
}