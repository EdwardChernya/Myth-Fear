/// @description Insert description here
// You can write your code in this editor

event_inherited();


if (!is_area_within_bounds(grid_x-1, grid_y-1, grid_x+1, grid_y)) {
	instance_destroy();
	exit;
}

var _x = grid_x*cell + 7;
var _y = grid_y*cell;

destroy_square_area_grid(grid_x-1, grid_y-1, grid_x+1, grid_y);

var asset = new static_asset(_x, _y, grid_x, grid_y, "pillar");
asset.sprite_index = sprite_index;
asset.xscale = image_xscale;

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