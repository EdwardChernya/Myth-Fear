/// @description Insert description here
// You can write your code in this editor

event_inherited();


if (image_xscale > 0) {
	if (!is_area_within_bounds(grid_x-6, grid_y-4, grid_x+2, grid_y+1)) {
		instance_destroy();
		exit;
	}
} else {
	if (!is_area_within_bounds(grid_x-2, grid_y-4, grid_x+6, grid_y+1)) {
		instance_destroy();
		exit;
	}
}

var _x = grid_x*cell + 7;
var _y = grid_y*cell;

if (image_xscale > 0) {
	destroy_square_area_grid(grid_x-5, grid_y-3, grid_x+1, grid_y);
} else {
	destroy_square_area_grid(grid_x-1, grid_y-3, grid_x+5, grid_y);
}

var asset = new static_asset(_x, _y, grid_x, grid_y, "arc");
asset.sprite_index = sprite_index;
asset.xscale = image_xscale;

if (broken && irandom(9) > 1) {
	insert_static_asset(asset);
	MAP.collision_grid[grid_x][grid_y]     = "blocked";
	MAP.collision_grid[grid_x-1][grid_y-1] = "blocked";
	MAP.collision_grid[grid_x][grid_y-1]   = "blocked";
	MAP.collision_grid[grid_x+1][grid_y-1] = "blocked";
	MAP.assets_grid[grid_x][grid_y]     = asset;
	MAP.assets_grid[grid_x-1][grid_y-1] = asset;
	MAP.assets_grid[grid_x][grid_y-1]   = asset;
	MAP.assets_grid[grid_x+1][grid_y-1] = asset;
} else if (!broken) {
	insert_static_asset(asset);
	MAP.collision_grid[grid_x][grid_y]     = "blocked";
	MAP.collision_grid[grid_x-1][grid_y-1] = "blocked";
	MAP.collision_grid[grid_x][grid_y-1]   = "blocked";
	MAP.collision_grid[grid_x+1][grid_y-1] = "blocked";
	MAP.assets_grid[grid_x][grid_y]     = asset;
	MAP.assets_grid[grid_x-1][grid_y-1] = asset;
	MAP.assets_grid[grid_x][grid_y-1]   = asset;
	MAP.assets_grid[grid_x+1][grid_y-1] = asset;
}

var destroy_func = function(_self) {
	with (_self) {
		MAP.collision_grid[grid_x][grid_y]     = "free";
		MAP.collision_grid[grid_x-1][grid_y-1] = "free";
		MAP.collision_grid[grid_x][grid_y-1]   = "free";
		MAP.collision_grid[grid_x+1][grid_y-1] = "free";
		MAP.assets_grid[grid_x][grid_y]     = undefined;
		MAP.assets_grid[grid_x-1][grid_y-1] = undefined;
		MAP.assets_grid[grid_x][grid_y-1]   = undefined;
		MAP.assets_grid[grid_x+1][grid_y-1] = undefined;
	}
}
asset.destroy_function = destroy_func;


// second part of arc

if (image_xscale<0) {
	grid_x += 4;
	var _x = grid_x*cell + 5;
} else {
	grid_x -= 4;
	var _x = grid_x*cell + 9;
}
grid_y -= 2;
var _y = grid_y*cell + 7;

var asset = new static_asset(_x, _y, grid_x, grid_y, "arc");
asset.sprite_index = dungeon_arc2;
asset.xscale = image_xscale;

if (broken && irandom(9) > 2) {
	insert_static_asset(asset);
	MAP.collision_grid[grid_x][grid_y]     = "blocked";
	MAP.collision_grid[grid_x-1][grid_y] = "blocked";
	MAP.collision_grid[grid_x+1][grid_y] = "blocked";
	MAP.assets_grid[grid_x][grid_y]     = asset;
	MAP.assets_grid[grid_x-1][grid_y] = asset;
	MAP.assets_grid[grid_x+1][grid_y] = asset;
} else if (!broken) {
	insert_static_asset(asset);
	MAP.collision_grid[grid_x][grid_y]     = "blocked";
	MAP.collision_grid[grid_x-1][grid_y] = "blocked";
	MAP.collision_grid[grid_x+1][grid_y] = "blocked";
	MAP.assets_grid[grid_x][grid_y]     = asset;
	MAP.assets_grid[grid_x-1][grid_y] = asset;
	MAP.assets_grid[grid_x+1][grid_y] = asset;
}

var destroy_func = function(_self) {
	with (_self) {
		MAP.collision_grid[grid_x][grid_y]     = "free";
		MAP.collision_grid[grid_x-1][grid_y] = "free";
		MAP.collision_grid[grid_x+1][grid_y] = "free";
		MAP.assets_grid[grid_x][grid_y]     = undefined;
		MAP.assets_grid[grid_x-1][grid_y] = undefined;
		MAP.assets_grid[grid_x+1][grid_y] = undefined;
	}
}
asset.destroy_function = destroy_func;



instance_destroy();