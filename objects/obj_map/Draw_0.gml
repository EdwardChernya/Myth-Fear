/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;

// draw background surfaces
draw_background_surfaces();
draw_background_fog();

#region draw static and dynamic assets with culling

// find camera bounds on grid
var cell = collision_grid_cell_size;
var padding = 9;
var start_x = max(0, floor((CAMERA.x - CAMERA.world_width/2)/cell) -padding);
var start_y = max(0, floor((CAMERA.y - CAMERA.world_height/2)/cell) -padding);
var end_x = min(collision_grid_size, floor((CAMERA.x + CAMERA.world_width/2)/cell) +padding);
var end_y = min(collision_grid_size, floor((CAMERA.y + CAMERA.world_height/2)/cell) +padding);

// grab all static asssets inside camera bounds
var culled_array = [];
for (var yy =start_y; yy < end_y; yy++) {
	for (var xx =start_x; xx < end_x; xx++) {
		if (static_assets[xx][yy] != undefined) array_push(culled_array, static_assets[xx][yy]);
	}
}
sort_by_y(culled_array);
// start drawing
var static_index = 0;
var dynamic_index = 0;
var static_count = array_length(culled_array);
var dynamic_count = array_length(dynamic_assets);
CAMERA.assets_drawn = static_count + dynamic_count;
// Merge draw static and dynamic assets in correct depth order
while (static_index < static_count && dynamic_index < dynamic_count) {
    if (culled_array[static_index].y <= dynamic_assets[dynamic_index].y) {
        // Static asset should draw first (lower Y = further back)
        culled_array[static_index].draw();
        static_index++;
    } else {
        // Dynamic asset should draw first
        dynamic_assets[dynamic_index].draw();
        dynamic_index++;
    }
}
// Draw any remaining static assets
while (static_index < static_count) {
    culled_array[static_index].draw();
    static_index++;
}
// Draw any remaining dynamic assets  
while (dynamic_index < dynamic_count) {
    dynamic_assets[dynamic_index].draw();
    dynamic_index++;
}

#endregion

// draw fog
if (!DEV) draw_fog();
fog_sprite_index += 1/60;
if (fog_sprite_index > sprite_get_number(bg_stars_256)) fog_sprite_index = 0;


#region dev visuals
if (!DEV) exit;

// draw stuff
for (var i=0; i<array_length(collision_grid); i++) {
	var s = collision_grid_cell_size;
	draw_set_alpha(.25);
	var c = c_fuchsia;
	for (var j=0; j<array_length(collision_grid[i]); j++) {
		if (collision_grid[i][j] == "blocked") draw_rectangle_color(i*s, j*s, i*s+s-1, j*s+s-1, c, c, c, c, false);
	}
	draw_set_alpha(1);
}

// draw assets grid
for (var i=0; i<array_length(assets_grid); i++) {
	var s = collision_grid_cell_size;
	draw_set_alpha(.25);
	for (var j=0; j<array_length(assets_grid[i]); j++) {
		if (assets_grid[i][j] != undefined) {
			var c = c_blue;
			if (assets_grid[i][j].type == "rock") c = c_red;
			draw_rectangle_color(i*s, j*s, i*s+s-1, j*s+s-1, c, c, c, c, false);
		}
	}
	draw_set_alpha(1);
}



draw_set_color(c_lime);

// Draw connections
for (var i = 0; i < array_length(map_nodes); i++) {
    var node = map_nodes[i];
        
    for (var j = 0; j < array_length(node.connections); j++) {
        var other_node = map_nodes[node.connections[j]];
		var c1 = node.is_last ? c_fuchsia : c_lime;
		var c2 = other_node.is_last ? c_fuchsia : c_lime;
        draw_line_color(node.x, node.y, other_node.x, other_node.y, c1, c2);
    }
}
    
#endregion
