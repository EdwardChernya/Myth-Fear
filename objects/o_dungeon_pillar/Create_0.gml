/// @description Insert description here
// You can write your code in this editor

event_inherited();

var _x = grid_x*cell + 7;
var _y = grid_y*cell;

var asset = new static_asset(_x, _y, "pillar");
asset.sprite_index = sprite_index;
asset.xscale = image_xscale;

insert_static_asset(asset);
MAP.assets_grid[grid_x][grid_y] = asset;

mark_square_area_grid(grid_x-1, grid_y-1, grid_x+1, grid_y, "blocked");

instance_destroy();