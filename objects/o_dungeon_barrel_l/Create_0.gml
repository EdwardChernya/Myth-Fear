/// @description Insert description here
// You can write your code in this editor

event_inherited();


if (!is_area_within_bounds(grid_x-1, grid_y, grid_x, grid_y)) {
	instance_destroy();
	exit;
}

var _x = grid_x*cell;
var _y = grid_y*cell + 7;

destroy_square_area_grid(grid_x-1, grid_y, grid_x, grid_y);

var asset = new static_asset(_x, _y, grid_x, grid_y, "barrel large");
asset.sprite_index = sprite_index;
asset.xscale = image_xscale;

insert_static_asset(asset);
MAP.collision_grid[grid_x][grid_y] = "blocked";
MAP.collision_grid[grid_x-1][grid_y] = "blocked";
MAP.assets_grid[grid_x][grid_y] = asset;
MAP.assets_grid[grid_x-1][grid_y] = asset;

var destroy_func = function(_self) {
	with (_self) {
		MAP.collision_grid[grid_x][grid_y] = "free";
		MAP.collision_grid[grid_x-1][grid_y] = "free";
		MAP.assets_grid[grid_x][grid_y] = undefined;
		MAP.assets_grid[grid_x-1][grid_y] = undefined;
		var destroy_asset = new static_asset(x, y, grid_x, grid_y, "broken barrel large");
		destroy_asset.sprite_index = dungeon_barrel_l_broken;
		destroy_asset.xscale = xscale;
		destroy_asset.update_function = function(_self) {
			with (_self) {
				alpha -= 1/60;
				if (alpha <= 0) clear(MAP.dynamic_assets);
			}
		}
		array_push(MAP.dynamic_assets, destroy_asset);
	}
}
asset.destroy_function = destroy_func;



instance_destroy();