/// @description Insert description here
// You can write your code in this editor

event_inherited();



if (!is_area_within_bounds(grid_x-4, grid_y-2, grid_x+3, grid_y+2)) {
	instance_destroy();
	exit;
}


var _x = grid_x*cell;
var _y = grid_y*cell;


destroy_ellipse_area(_x-image_xscale*cell, _y, cell*5, .7);

if (image_xscale < 0) _x += cell;

var asset = new static_asset(_x, _y, grid_x, grid_y, "tent");
asset.sprite_index = sprite_index;
asset.xscale = image_xscale;

insert_static_asset(asset);
MAP.collision_grid[grid_x][grid_y]     = "blocked";
MAP.collision_grid[grid_x][grid_y+1]   = "blocked";
MAP.collision_grid[grid_x][grid_y+2]   = "blocked";
MAP.collision_grid[grid_x+1*image_xscale][grid_y]   = "blocked";
MAP.collision_grid[grid_x+1*image_xscale][grid_y+1] = "blocked";
MAP.collision_grid[grid_x+2*image_xscale][grid_y]   = "blocked";
MAP.collision_grid[grid_x+2*image_xscale][grid_y+1]   = "blocked";
MAP.collision_grid[grid_x+3*image_xscale][grid_y]   = "blocked";
MAP.collision_grid[grid_x-1*image_xscale][grid_y]   = "blocked";
MAP.collision_grid[grid_x-1*image_xscale][grid_y+1] = "blocked";
MAP.collision_grid[grid_x-1*image_xscale][grid_y+2] = "blocked";
MAP.collision_grid[grid_x-2*image_xscale][grid_y]   = "blocked";
MAP.collision_grid[grid_x-2*image_xscale][grid_y+1]   = "blocked";
MAP.collision_grid[grid_x-3*image_xscale][grid_y]   = "blocked";
MAP.collision_grid[grid_x][grid_y-1]   = "blocked";
MAP.collision_grid[grid_x][grid_y-2]   = "blocked";
MAP.collision_grid[grid_x+1*image_xscale][grid_y-1] = "blocked";
MAP.collision_grid[grid_x+1*image_xscale][grid_y-2] = "blocked";
MAP.collision_grid[grid_x+2*image_xscale][grid_y-1] = "blocked";
MAP.collision_grid[grid_x-1*image_xscale][grid_y-1] = "blocked";
MAP.collision_grid[grid_x-1*image_xscale][grid_y-2] = "blocked";
MAP.collision_grid[grid_x-2*image_xscale][grid_y-1] = "blocked";
MAP.collision_grid[grid_x-2*image_xscale][grid_y-2] = "blocked";
MAP.collision_grid[grid_x-3*image_xscale][grid_y-1] = "blocked";
MAP.collision_grid[grid_x-4*image_xscale][grid_y-1] = "blocked";

MAP.assets_grid[grid_x][grid_y]     = asset;
MAP.assets_grid[grid_x][grid_y+1]   = asset;
MAP.assets_grid[grid_x][grid_y+2]   = asset;
MAP.assets_grid[grid_x+1*image_xscale][grid_y]   = asset;
MAP.assets_grid[grid_x+1*image_xscale][grid_y+1] = asset;
MAP.assets_grid[grid_x+2*image_xscale][grid_y]   = asset;
MAP.assets_grid[grid_x+2*image_xscale][grid_y+1]   = asset;
MAP.assets_grid[grid_x+3*image_xscale][grid_y]   = asset;
MAP.assets_grid[grid_x-1*image_xscale][grid_y]   = asset;
MAP.assets_grid[grid_x-1*image_xscale][grid_y+1] = asset;
MAP.assets_grid[grid_x-1*image_xscale][grid_y+2] = asset;
MAP.assets_grid[grid_x-2*image_xscale][grid_y]   = asset;
MAP.assets_grid[grid_x-2*image_xscale][grid_y+1] = asset;
MAP.assets_grid[grid_x-3*image_xscale][grid_y]   = asset;
MAP.assets_grid[grid_x][grid_y-1]   = asset;
MAP.assets_grid[grid_x][grid_y-2]   = asset;
MAP.assets_grid[grid_x+1*image_xscale][grid_y-1] = asset;
MAP.assets_grid[grid_x+1*image_xscale][grid_y-2] = asset;
MAP.assets_grid[grid_x+2*image_xscale][grid_y-1] = asset;
MAP.assets_grid[grid_x-1*image_xscale][grid_y-1] = asset;
MAP.assets_grid[grid_x-1*image_xscale][grid_y-2] = asset;
MAP.assets_grid[grid_x-2*image_xscale][grid_y-1] = asset;
MAP.assets_grid[grid_x-2*image_xscale][grid_y-2] = asset;
MAP.assets_grid[grid_x-3*image_xscale][grid_y-1] = asset;
MAP.assets_grid[grid_x-4*image_xscale][grid_y-1] = asset;

var destroy_func = function(_self) {
	with (_self) {
		MAP.collision_grid[grid_x][grid_y]            = "free";
		MAP.collision_grid[grid_x][grid_y+1]          = "free";
		MAP.collision_grid[grid_x][grid_y+2]          = "free";
		MAP.collision_grid[grid_x+1*xscale][grid_y]   = "free";
		MAP.collision_grid[grid_x+1*xscale][grid_y+1] = "free";
		MAP.collision_grid[grid_x+2*xscale][grid_y]   = "free";
		MAP.collision_grid[grid_x+2*xscale][grid_y+1]   = "free";
		MAP.collision_grid[grid_x+3*xscale][grid_y]   = "free";
		MAP.collision_grid[grid_x-1*xscale][grid_y]   = "free";
		MAP.collision_grid[grid_x-1*xscale][grid_y+1] = "free";
		MAP.collision_grid[grid_x-1*xscale][grid_y+2] = "free";
		MAP.collision_grid[grid_x-2*xscale][grid_y]   = "free";
		MAP.collision_grid[grid_x-2*xscale][grid_y+1] = "free";
		MAP.collision_grid[grid_x-3*xscale][grid_y]   = "free";
		MAP.collision_grid[grid_x][grid_y-1]          = "free";
		MAP.collision_grid[grid_x][grid_y-2]          = "free";
		MAP.collision_grid[grid_x+1*xscale][grid_y-1] = "free";
		MAP.collision_grid[grid_x+1*xscale][grid_y-2] = "free";
		MAP.collision_grid[grid_x+2*xscale][grid_y-1] = "free";
		MAP.collision_grid[grid_x-1*xscale][grid_y-1] = "free";
		MAP.collision_grid[grid_x-1*xscale][grid_y-2] = "free";
		MAP.collision_grid[grid_x-2*xscale][grid_y-1] = "free";
		MAP.collision_grid[grid_x-2*xscale][grid_y-2] = "free";
		MAP.collision_grid[grid_x-3*xscale][grid_y-1] = "free";
		MAP.collision_grid[grid_x-4*xscale][grid_y-1] = "free";

		MAP.assets_grid[grid_x][grid_y]            = undefined;
		MAP.assets_grid[grid_x][grid_y+1]          = undefined;
		MAP.assets_grid[grid_x][grid_y+2]          = undefined;
		MAP.assets_grid[grid_x+1*xscale][grid_y]   = undefined;
		MAP.assets_grid[grid_x+1*xscale][grid_y+1] = undefined;
		MAP.assets_grid[grid_x+2*xscale][grid_y]   = undefined;
		MAP.assets_grid[grid_x+2*xscale][grid_y+1]   = undefined;
		MAP.assets_grid[grid_x+3*xscale][grid_y]   = undefined;
		MAP.assets_grid[grid_x-1*xscale][grid_y]   = undefined;
		MAP.assets_grid[grid_x-1*xscale][grid_y+1] = undefined;
		MAP.assets_grid[grid_x-1*xscale][grid_y+2] = undefined;
		MAP.assets_grid[grid_x-2*xscale][grid_y]   = undefined;
		MAP.assets_grid[grid_x-2*xscale][grid_y+1] = undefined;
		MAP.assets_grid[grid_x-3*xscale][grid_y]   = undefined;
		MAP.assets_grid[grid_x][grid_y-1]          = undefined;
		MAP.assets_grid[grid_x][grid_y-2]          = undefined;
		MAP.assets_grid[grid_x+1*xscale][grid_y-1] = undefined;
		MAP.assets_grid[grid_x+1*xscale][grid_y-2] = undefined;
		MAP.assets_grid[grid_x+2*xscale][grid_y-1] = undefined;
		MAP.assets_grid[grid_x-1*xscale][grid_y-1] = undefined;
		MAP.assets_grid[grid_x-1*xscale][grid_y-2] = undefined;
		MAP.assets_grid[grid_x-2*xscale][grid_y-1] = undefined;
		MAP.assets_grid[grid_x-2*xscale][grid_y-2] = undefined;
		MAP.assets_grid[grid_x-3*xscale][grid_y-1] = undefined;
		MAP.assets_grid[grid_x-4*xscale][grid_y-1] = undefined;
	}
}
asset.destroy_function = destroy_func;




instance_destroy();