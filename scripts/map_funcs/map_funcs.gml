// script goes brrrrrr
function init_map(_type){
	MAP.type = _type;
	
	// set room size
	room_set_width(Room1, MAP.size*TILE);
	room_set_height(Room1, MAP.size*TILE);
	
	randomize();
	var r = irandom_range(MAP.size-MAP.size/3, MAP.size+MAP.size/3);
	MAP.map_nodes = create_spiral_map(MAP.size*TILE, r, r*2);
	DEBUG.add($"main {r} | total {array_length(MAP.map_nodes)}", c_lime);
	
	init_collision_grid();
	
	room_goto(Room1);
	PLAYER.position.Set(MAP.map_nodes[0]);
	
	
}

#region collision grid

function init_collision_grid() {
    
    // Create 2D grid array - false = walkable, true = blocked
    var collision_grid = array_create(MAP.collision_grid_size);
    for (var _x = 0; _x < MAP.collision_grid_size; _x++) {
        collision_grid[_x] = array_create(MAP.collision_grid_size, false);
    }
    MAP.collision_grid = collision_grid;
    // Mark node areas as blocked
    mark_node_collisions();
    
}

function mark_node_collisions() {
    // Mark areas around nodes as blocked
    for (var i = 0; i < array_length(MAP.map_nodes); i++) {
        var node = MAP.map_nodes[i];
        mark_circle_area(node.x, node.y, 125); // Block radius around nodes
    }
    
    // Mark areas around connections (roads) as blocked
    for (var i = 0; i < array_length(MAP.map_nodes); i++) {
        var node = MAP.map_nodes[i];
        for (var j = 0; j < array_length(node.connections); j++) {
            var other_node = MAP.map_nodes[node.connections[j]];
            mark_line_area(node.x, node.y, other_node.x, other_node.y, 75); // Road width
        }
    }
}

function is_position_walkable(x, y) {
    var grid_x = floor(x / MAP.collision_grid_cell_size);
    var grid_y = floor(y / MAP.collision_grid_cell_size);
    
    if (grid_x >= 0 && grid_x < MAP.collision_grid_size && 
        grid_y >= 0 && grid_y < MAP.collision_grid_size ) {
        return MAP.collision_grid[grid_x][grid_y];
    }
    
    return false; // Block out-of-bounds positions
}

function mark_circle_area(center_x, center_y, radius) {
    var grid_radius = ceil(radius / MAP.collision_grid_cell_size);
    var center_grid_x = floor(center_x / MAP.collision_grid_cell_size);
    var center_grid_y = floor(center_y / MAP.collision_grid_cell_size);
    
    for (var dx = -grid_radius; dx <= grid_radius; dx++) {
        for (var dy = -grid_radius; dy <= grid_radius; dy++) {
            var grid_x = center_grid_x + dx;
            var grid_y = center_grid_y + dy;
            
            if (grid_x >= 0 && grid_x < MAP.collision_grid_size && 
                grid_y >= 0 && grid_y < MAP.collision_grid_size) {
                
                // Check if this grid cell is within the circle
                var world_x = grid_x * MAP.collision_grid_cell_size + MAP.collision_grid_cell_size / 2;
                var world_y = grid_y * MAP.collision_grid_cell_size + MAP.collision_grid_cell_size / 2;
                if (point_distance(center_x, center_y, world_x, world_y) <= radius) {
                    MAP.collision_grid[grid_x][grid_y] = true;
                }
            }
        }
    }
}

function mark_line_area(x1, y1, x2, y2, width) {
    var steps = point_distance(x1, y1, x2, y2) / MAP.collision_grid_cell_size;
    for (var i = 0; i <= steps; i++) {
        var t = i / steps;
        var line_x = lerp(x1, x2, t);
        var line_y = lerp(y1, y2, t);
        mark_circle_area(line_x, line_y, width / 2);
    }
}

#endregion

#region map 

function create_spiral_map(map_size, trunk_nodes = 8, max_branches = 5) {
    var nodes = [];
    
    // Start from a random point
    var start_x = map_size/2 + random_range(-100, 100);
    var start_y = map_size/2 + random_range(-100, 100);
    
    // Spiral parameters
    var spiral_tightness = 1 + random_range(-.1, .1);
    var spiral_expansion = 64;
    var base_angle = random(360);
    var angle_increment = spiral_expansion;
    
    // Create main trunk as a spiral
    var current_x = start_x;
    var current_y = start_y;
    var current_angle = base_angle;
    var current_radius = 0;
    
    for (var i = 0; i < trunk_nodes; i++) {
        // Spiral formula: radius grows, angle increases
        current_radius += spiral_expansion * (100/(100+current_radius*0.5));
		var dynamic_angle_increment = angle_increment * (100/(100+current_radius*0.5));
        current_angle += dynamic_angle_increment * spiral_tightness;
        
        var spiral_x = start_x + lengthdir_x(current_radius, current_angle);
        var spiral_y = start_y + lengthdir_y(current_radius, current_angle);
        
        // Add some noise to make it more organic
        var noise_x = (noise(i * 0.3) - 0.5) * 40;
        var noise_y = (noise(i * 0.3 + 1000) - 0.5) * 40;
        
        var node_x = spiral_x + noise_x;
        var node_y = spiral_y + noise_y;
        
        // Keep within bounds
        node_x = clamp(node_x, 50, map_size - 50);
        node_y = clamp(node_y, 50, map_size - 50);
        
        // Check for collisions
		var valid_pos = find_valid_position(nodes, node_x, node_y, 100, map_size);
		if (valid_pos[0] != -1) {
            node_x = valid_pos[0];
            node_y = valid_pos[1];
            node_x = clamp(node_x, 50, map_size - 50);
            node_y = clamp(node_y, 50, map_size - 50);
        } else { // retry with different parameters
			spiral_expansion *= 1.2;
			angle_increment *= 0.9;
			i--;
			continue;
		}
        
        var node = {
            x: node_x,
            y: node_y,
            connections: [],
            is_trunk: true
        };
        
        array_push(nodes, node);
        
        // Connect to previous trunk node (if not first node)
        if (i > 0) {
            array_push(nodes[i-1].connections, i);
            array_push(nodes[i].connections, i-1);
        }
        
        current_x = node_x;
        current_y = node_y;
    }
    
    // Add spiral branches that follow similar patterns
    for (var i = 1; i < trunk_nodes - 1; i++) {
        if (random(1) < 0.5) { // 50% chance to branch
            add_spiral_branch(nodes, i, map_size, 2 + irandom(3));
        }
    }
    
    return nodes;
}

function add_spiral_branch(nodes, from_index, map_size, branch_length) {
    var from_node = nodes[from_index];
    var last_index = from_index;
    
    // Each branch has its own spiral parameters
    var branch_angle = random(360);
    var branch_angle_inc = random_range(25, 60) * choose(-1, 1); // Can spiral clockwise or counter
    var branch_radius = 0;
    var branch_expansion = random_range(10, 25);
    
    for (var i = 0; i < branch_length; i++) {
        var last_node = nodes[last_index];
        
        // Spiral out from last node
        branch_radius += branch_expansion;
        branch_angle += branch_angle_inc;
        
        var spiral_x = last_node.x + lengthdir_x(branch_radius, branch_angle);
        var spiral_y = last_node.y + lengthdir_y(branch_radius, branch_angle);
        
        // Add organic noise
        var noise_x = (noise(i * 0.4 + 2000) - 0.5) * 30;
        var noise_y = (noise(i * 0.4 + 3000) - 0.5) * 30;
        
        var branch_x = spiral_x + noise_x;
        var branch_y = spiral_y + noise_y;
        
        // Keep within bounds
        branch_x = clamp(branch_x, 50, map_size - 50);
        branch_y = clamp(branch_y, 50, map_size - 50);
        
        // Check for collisions
		var valid_pos = find_valid_position(nodes, branch_x, branch_y, 100, map_size);
		if (valid_pos[0] != -1) {
            branch_x = valid_pos[0];
            branch_y = valid_pos[1];
            branch_x = clamp(branch_x, 50, map_size - 50);
            branch_y = clamp(branch_y, 50, map_size - 50);
        } else {
			break;
		}
        
        var new_node = {
            x: branch_x,
            y: branch_y,
            connections: [],
            is_trunk: false
        };
        
        var new_index = array_length(nodes);
        array_push(nodes, new_node);
        
        // Connect to previous node in branch
        array_push(nodes[last_index].connections, new_index);
        array_push(nodes[new_index].connections, last_index);
        
        last_index = new_index;
        
        // Chance to add a micro-branch (very short spirals)
        if (i > 0 && random(1) < 0.25) {
            add_micro_spiral(nodes, last_index, map_size);
        }
    }
}

function add_micro_spiral(nodes, from_index, map_size) {
    var from_node = nodes[from_index];
    var last_index = from_index;
    
    var micro_length = 1 + irandom(1);
    var micro_angle = random(360);
    var micro_angle_inc = random_range(40, 80);
    var micro_radius = 0;
    
    for (var i = 0; i < micro_length; i++) {
        var last_node = nodes[last_index];
        
        micro_radius += random_range(8, 20);
        micro_angle += micro_angle_inc;
        
        var micro_x = last_node.x + lengthdir_x(micro_radius, micro_angle);
        var micro_y = last_node.y + lengthdir_y(micro_radius, micro_angle);
        
        micro_x = clamp(micro_x, 50, map_size - 50);
        micro_y = clamp(micro_y, 50, map_size - 50);
        
        // Quick collision check
        if (!is_too_close_to_any_node(nodes, micro_x, micro_y, 100)) {
            var new_node = {
                x: micro_x,
                y: micro_y,
                connections: [],
                is_trunk: false
            };
            
            var new_index = array_length(nodes);
            array_push(nodes, new_node);
            
            array_push(nodes[last_index].connections, new_index);
            array_push(nodes[new_index].connections, last_index);
            
            last_index = new_index;
        }
    }
}

function is_too_close_to_any_node(nodes, _x, _y, min_distance) {
    for (var i = 0; i < array_length(nodes); i++) {
        if (point_distance(_x, _y, nodes[i].x, nodes[i].y) < min_distance) {
            return true;
        }
    }
    return false;
}

function find_valid_position(nodes, intended_x, intended_y, min_distance, map_size, max_attempts = 50) {
    var attempts = 0;
    var search_radius = 0;
    var angle = 0;
    
    while (attempts < max_attempts) {
        // Search in expanding circles around intended position
        for (var a = 0; a < 360; a += 30) { // Check 12 points around circle
            var test_x = intended_x + lengthdir_x(search_radius, a);
            var test_y = intended_y + lengthdir_y(search_radius, a);
            
            test_x = clamp(test_x, 50, map_size - 50);
            test_y = clamp(test_y, 50, map_size - 50);
            
            if (!is_too_close_to_any_node(nodes, test_x, test_y, min_distance)) {
                return [test_x, test_y]; // Found valid position
            }
            attempts++;
        }
        search_radius += 20; // Expand search radius
    }
    
    return [-1, -1]; // No valid position found
}

function noise(seed) {
    return (sin(seed * 12.9898) * 43758.5453) % 1;
}

#endregion

#region assets

function place_rocks_simple(_type) {
    
	MAP.static_assets = [];
	
    // Define rock sizes and how many can fit in one cell
	switch (_type) {
		case "dungeon":
		    var rock_types = [
		        {sprite: dungeon_rock_s,   size: 30},
		        {sprite: dungeon_rock_s2,  size: 30}, 
		        {sprite: dungeon_rock_s3,  size: 30},
		        {sprite: dungeon_rock_s5,  size: 30},
		        {sprite: dungeon_rock_s6,  size: 30},
		        {sprite: dungeon_rock_s7,  size: 30},
		        {sprite: dungeon_rock_s8,  size: 30},
		        {sprite: dungeon_rock_s9,  size: 30},
		        {sprite: dungeon_rock_s10,  size: 30},
		        {sprite: dungeon_rock_s11,  size: 30},
		        {sprite: dungeon_rock_s12,  size: 30},
		        {sprite: dungeon_rock_s13,  size: 30},
		        {sprite: dungeon_rock_s14,  size: 30},
		        {sprite: dungeon_rock_s15,  size: 30},
		        {sprite: dungeon_rock_s16,  size: 30},
		        {sprite: dungeon_rock_s17,  size: 30},
		        {sprite: dungeon_rock_s18,  size: 30},
		        {sprite: dungeon_rock_s19,  size: 30},
		        {sprite: dungeon_rock_s20,  size: 30},
		        {sprite: dungeon_rock_m,   size: 30},
		    ];
			break;
	}
    
    // Place rock clusters
    place_rocks_around_edges(rock_types);
}

function place_rocks_around_edges(rock_types) {
    var grid_size = MAP.collision_grid_cell_size;
    
    // Scan the entire collision grid
    for (var i = 0; i < array_length(MAP.collision_grid); i++) {
        for (var j = 0; j < array_length(MAP.collision_grid[i]); j++) {
            // If this cell is not walkable...
            if (!MAP.collision_grid[i][j]) {
                // Check all 8 surrounding cells
                for (var dx = -1; dx <= 1; dx++) {
                    for (var dy = -1; dy <= 1; dy++) {
                        var check_x = i + dx;
                        var check_y = j + dy;
                        
                        // If we find a blocked cell next to a walkable cell, place rock
                        if (check_x >= 0 && check_x < array_length(MAP.collision_grid) &&
                            check_y >= 0 && check_y < array_length(MAP.collision_grid[check_x]) &&
                            MAP.collision_grid[check_x][check_y]) {
                            
                            var rock_x = i * grid_size + grid_size / 2;
                            var rock_y = j * grid_size + grid_size / 2;
                            
                            create_rock(rock_x, rock_y, rock_types[irandom(array_length(rock_types)-1)]);
                            break; // Only need one rock per edge cell
                        }
                    }
                }
            }
        }
    }
}
function create_rock(_x, _y, rock_type) {
    var rock = {
        x: _x,
        y: _y,
        sprite: rock_type.sprite,
        size: rock_type.size,
		scale : random_range(.35, 1),
		xscale : choose(-1, 1),
        draw: function() {
            draw_sprite_ext(sprite, 0, x, y, scale*xscale, scale, 0, c_white, 1);
        }
    };
    
    array_push(MAP.static_assets, rock);
    
    //return rock;
}

#endregion
