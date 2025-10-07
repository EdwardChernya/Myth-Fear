/// @description Insert description here
// You can write your code in this editor



// draw map dev visuals
if (!DEV) exit;

for (var i=0; i<array_length(collision_grid); i++) {
	var s = collision_grid_cell_size;
	for (var j=0; j<array_length(collision_grid[i]); j++) {
		if (collision_grid[i][j]) draw_rectangle_color(i*s, j*s, i*s+s, j*s+s, c_green, c_green, c_green, c_green, false);
	}
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
    
// Draw nodes
for (var i = 0; i < array_length(map_nodes); i++) {
    var node = map_nodes[i];
        
    if (node.is_trunk) {
        draw_set_color(c_red); // Trunk nodes in red
    } else {
        draw_set_color(c_blue); // Branch nodes in blue
    }
        
    draw_circle(node.x, node.y, 8, true);
}