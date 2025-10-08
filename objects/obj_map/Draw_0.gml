/// @description Insert description here
// You can write your code in this editor


// draw static assets
var player_drawn = false;
for (var i =0; i < array_length(static_assets); i++) {
	if (!player_drawn and static_assets[i].y < PLAYER.position.y and i < array_length(static_assets)-1 and static_assets[i+1].y > PLAYER.position.y) {
		PLAYER.character_main.draw();
		player_drawn = true;
	}
	static_assets[i].draw();
}
if (!player_drawn) PLAYER.character_main.draw();


// draw map dev visuals
if (!DEV) exit;

// draw walkable area
for (var i=0; i<array_length(collision_grid); i++) {
	var s = collision_grid_cell_size;
	draw_set_alpha(.25);
	for (var j=0; j<array_length(collision_grid[i]); j++) {
		if (collision_grid[i][j]) draw_rectangle_color(i*s, j*s, i*s+s-1, j*s+s-1, c_green, c_green, c_green, c_green, false);
	}
	draw_set_alpha(1);
}



draw_set_color(c_lime);

// Draw connections
for (var i = 0; i < array_length(map_nodes); i++) {
    var node = map_nodes[i];
        
    for (var j = 0; j < array_length(node.connections); j++) {
        var other_node = map_nodes[node.connections[j]];
        draw_line(node.x, node.y, other_node.x, other_node.y);
    }
}
    
