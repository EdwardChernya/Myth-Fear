/// @description Insert description here
// You can write your code in this editor

event_inherited();


if (!is_area_within_bounds(grid_x-1, grid_y-1, grid_x+1, grid_y)) {
	instance_destroy();
	exit;
}

var _x = grid_x*cell + 8;
var _y = grid_y*cell + 7;

destroy_square_area_grid(grid_x-1, grid_y-1, grid_x+1, grid_y);

var asset = new static_asset(_x, _y, grid_x, grid_y, "chest");
asset.sprite_index = sprite_index;
asset.xscale = image_xscale;
asset.active = true;
asset.effect_alpha = 1;
asset.draw_function = function(_self, _x, _y, _scale) {
	with (_self) {
		draw_simple(_x, _y, _scale);
		if (active) {
			var a = in_vision_grid(grid_x, grid_y) ? .3+get_sine() : 1;
			draw_sprite_ext(chest_add, 0, _x-12, _y-31, 1, 1, 0, c_white, a*effect_alpha);
		}
	}
}

insert_static_asset(asset);
mark_square_area_grid(MAP.collision_grid, grid_x-1, grid_y-1, grid_x+1, grid_y, "blocked");
mark_square_area_grid(MAP.assets_grid, grid_x-1, grid_y-1, grid_x+1, grid_y, asset);

var destroy_func = function(_self) {
	with (_self) {
		mark_square_area_grid(MAP.collision_grid, grid_x-1, grid_y-1, grid_x+1, grid_y, "free");
		mark_square_area_grid(MAP.assets_grid, grid_x-1, grid_y-1, grid_x+1, grid_y, undefined);
	}
}
asset.destroy_function = destroy_func;


instance_destroy();