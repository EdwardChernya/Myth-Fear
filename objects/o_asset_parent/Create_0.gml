/// @description Insert description here
// You can write your code in this editor

cell = MAP.collision_grid_cell_size;

grid_x = floor(x/cell);
grid_y = floor(y/cell);

if (!is_valid_grid_cell(grid_x, grid_y)) {
	instance_destroy();
	exit;
}