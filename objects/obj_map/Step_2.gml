/// @description Insert description here
// You can write your code in this editor


if (PAUSED || room != Room1) exit;

for (var i=0; i<array_length(dynamic_assets); i++) {
	dynamic_assets[i].update_end();
}


for (var i=0; i<array_length(interact_array); i++) {
	interact_array[i].update_end();
}


sort_by_y(dynamic_assets);


// find camera bounds on grid
var cell = collision_grid_cell_size;
var start_x = max(0, floor((CAMERA.x - CAMERA.world_width/2)/cell) -3);
var start_y = max(0, floor((CAMERA.y - CAMERA.world_height/2)/cell) -2);
var end_x = min(collision_grid_size, floor((CAMERA.x + CAMERA.world_width/2)/cell) +3);
var end_y = min(collision_grid_size, floor((CAMERA.y + CAMERA.world_height/2)/cell) +9);
cull_start_x = max(0, floor((CAMERA.x - CAMERA.world_width/2)/cell)-1);
cull_start_y = max(0, floor((CAMERA.y - CAMERA.world_height/2)/cell)-1);
cull_end_x = min(collision_grid_size, floor((CAMERA.x + CAMERA.world_width/2)/cell)+1);
cull_end_y = min(collision_grid_size, floor((CAMERA.y + CAMERA.world_height/2)/cell)+1);

// grab all static asssets inside camera bounds
culled_array = [];
for (var yy =start_y; yy < end_y; yy++) {
	for (var xx =start_x; xx < end_x; xx++) {
		if (static_assets[xx][yy] != undefined) array_push(culled_array, static_assets[xx][yy]);
	}
}
sort_by_y(culled_array);