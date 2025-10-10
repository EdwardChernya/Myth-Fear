/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;

// draw background surfaces
draw_background_surfaces();

draw_background_fog();

// draw static assets
var player_drawn = false;
for (var i =0; i < array_length(static_assets); i++) {
	if (!player_drawn && static_assets[i].y < PLAYER.position.y && i < array_length(static_assets)-1 && static_assets[i+1].y > PLAYER.position.y) {
		PLAYER.character_main.draw();
		player_drawn = true;
	}
	static_assets[i].draw();
}
if (!player_drawn) PLAYER.character_main.draw();

draw_fog();
fog_sprite_index += 1/60;
if (fog_sprite_index > sprite_get_number(bg_stars_256)) fog_sprite_index = 0;

// draw map dev visuals
if (!DEV) exit;

// draw islands areas
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
    
