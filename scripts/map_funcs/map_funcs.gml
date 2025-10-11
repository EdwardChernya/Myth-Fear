// script goes brrrrrr
function init_map(_type){
	MAP.type = _type;
	
	// set room size
	room_set_width(Room1, MAP.size*TILE);
	room_set_height(Room1, MAP.size*TILE);
	
	room_goto(Room1);
}

#region grids

function init_grids() {
    
    // Create 2D grid array - false = walkable, true = blocked
	var grids_size = MAP.collision_grid_size;
    var collision_grid = array_create(grids_size);
	var assets_grid = array_create(grids_size);
	var static_assets = array_create(grids_size);
	var fog_grid = array_create(grids_size);
    for (var _x = 0; _x < grids_size; _x++) {
        collision_grid[_x] = array_create(grids_size, "outside");
		assets_grid[_x] = array_create(grids_size, undefined);
		static_assets[_x] = array_create(grids_size, undefined);
		fog_grid[_x] = array_create(grids_size, "fog");
    }
    MAP.collision_grid = collision_grid;
	MAP.assets_grid = assets_grid;
	MAP.fog_grid = fog_grid;
	MAP.static_assets = static_assets;
    // Mark node areas as blocked
    mark_node_collisions();
    // flag stuff
	flag_unwalkable_islands();
}

function mark_node_collisions() { // roads and collisions
    // Mark areas around nodes as blocked
    for (var i = 0; i < array_length(MAP.map_nodes); i++) {
        var node = MAP.map_nodes[i];
        mark_circle_area(node.x, node.y, 125, "free"); // Block radius around nodes
		mark_asset_circle_area(node.x, node.y, 15 + irandom(15), new static_asset(0, 0, 0, 0, "path"));
    }
    
    // Mark areas around connections (roads) as blocked
    for (var i = 0; i < array_length(MAP.map_nodes); i++) {
        var node = MAP.map_nodes[i];
        for (var j = 0; j < array_length(node.connections); j++) {
            var other_node = MAP.map_nodes[node.connections[j]];
            mark_line_area(node.x, node.y, other_node.x, other_node.y, 75, "free"); // Road width
            mark_asset_line_area(node.x, node.y, other_node.x, other_node.y, 5+irandom(15), new static_asset(0, 0, 0, 0,"path")); // Road width
        }
    }
}

function is_position_walkable(x, y) {
    var grid_x = floor(x / MAP.collision_grid_cell_size);
    var grid_y = floor(y / MAP.collision_grid_cell_size);
    
    if (is_valid_grid_cell(grid_x, grid_y)) {
        return (MAP.collision_grid[grid_x][grid_y] == "free");
    }
    
    return false; // Block out-of-bounds positions
}

function is_valid_grid_cell(x, y) {
    return (x >= 0 && x < MAP.collision_grid_size && 
            y >= 0 && y < MAP.collision_grid_size);
}

function flag_at_position(_x, _y, _grid) {
	var xx = to_grid(_x, MAP.collision_grid_cell_size);
	var yy = to_grid(_y, MAP.collision_grid_cell_size);
	return _grid[xx][yy];
}

function mark_circle_area(center_x, center_y, radius, _type) {
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
                    MAP.collision_grid[grid_x][grid_y] = _type;
                }
            }
        }
    }
}

function mark_line_area(x1, y1, x2, y2, width, _type) {
    var steps = point_distance(x1, y1, x2, y2) / MAP.collision_grid_cell_size;
    for (var i = 0; i <= steps; i++) {
        var t = i / steps;
        var line_x = lerp(x1, x2, t);
        var line_y = lerp(y1, y2, t);
        mark_circle_area(line_x, line_y, width / 2, _type);
    }
}

function mark_square_area_grid(grid, x1, y1, x2, y2, _type) {
    var grid_width = array_length(grid);
    var grid_height = array_length(grid[0]);
    
    // Clamp coordinates to grid bounds
    var start_x = clamp(x1, 0, grid_width - 1);
    var start_y = clamp(y1, 0, grid_height - 1);
    var end_x = clamp(x2+1, 0, grid_width);
    var end_y = clamp(y2+1, 0, grid_height);
    
    for (var xx = start_x; xx < end_x; xx++) {
        for (var yy = start_y; yy < end_y; yy++) {
            grid[xx][yy] = _type;
        }
    }
}

function mark_square_area_grid_filter(grid, x1, y1, x2, y2, _type, _filter) {
    var grid_width = array_length(grid);
    var grid_height = array_length(grid[0]);
    
    // Clamp coordinates to grid bounds
    var start_x = clamp(x1, 0, grid_width - 1);
    var start_y = clamp(y1, 0, grid_height - 1);
    var end_x = clamp(x2+1, 0, grid_width);
    var end_y = clamp(y2+1, 0, grid_height);
    
    for (var xx = start_x; xx < end_x; xx++) {
        for (var yy = start_y; yy < end_y; yy++) {
            if (grid[xx][yy] == _filter) grid[xx][yy] = _type;
        }
    }
}


function mark_asset_circle_area(center_x, center_y, radius, _mark) {
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
                    MAP.assets_grid[grid_x][grid_y] = _mark;
                }
            }
        }
    }
}

function mark_asset_line_area(x1, y1, x2, y2, width, _mark) {
    var steps = point_distance(x1, y1, x2, y2) / MAP.collision_grid_cell_size;
    for (var i = 0; i <= steps; i++) {
        var t = i / steps;
        var line_x = lerp(x1, x2, t);
        var line_y = lerp(y1, y2, t);
        mark_asset_circle_area(line_x, line_y, width / 2, _mark);
    }
}

function flag_unwalkable_islands() {
	var islands = find_unwalkable_islands();
	for (var i=0; i<array_length(islands); i++) {
		for (var j=0; j<array_length(islands[i]); j++) {
			var xx = islands[i][j][0], yy = islands[i][j][1];
			MAP.collision_grid[xx][yy] = "island";
		}
	}
	DEBUG.add($"{array_length(islands)} islands flagged", c_fuchsia);
}

function find_unwalkable_islands() {
    var grid = MAP.collision_grid;
    var grid_width = array_length(grid);
    var grid_height = array_length(grid[0]);
    
    var visited = array_create(grid_width);
    for (var xx = 0; xx < grid_width; xx++) {
        visited[xx] = array_create(grid_height, false);
    }
    
    var islands = [];
    
    for (var xx = 0; xx < grid_width; xx++) {
        for (var yy = 0; yy < grid_height; yy++) {
            // If cell is UNwalkable (blocked) and not visited, it's a potential island
            if (grid[xx][yy] != "free" && !visited[xx][yy]) {  // Changed to grid[xx][yy] (true = blocked)
                var island_cells = [];
                var touches_edge = flood_fill_unwalkable(xx, yy, grid, visited, island_cells);
                
                // Only keep islands that DON'T touch the map edges (true islands)
                if (!touches_edge && array_length(island_cells) > 0) {
                    array_push(islands, island_cells);
                }
            }
        }
    }
    
    return islands;
}

function flood_fill_unwalkable(start_xx, start_yy, grid, visited, island_cells) {
    var grid_width = array_length(grid);
    var grid_height = array_length(grid[0]);
    
    var queue = [[start_xx, start_yy]];
    visited[start_xx][start_yy] = true;
    var touches_edge = false;
    
    while (array_length(queue) > 0) {
        var cell = queue[0];
        array_delete(queue, 0, 1);
        var cell_x = cell[0], cell_y = cell[1];
        
        array_push(island_cells, [cell_x, cell_y]);
        
        // Check if this cell is on the edge of the map
        if (cell_x == 0 || cell_x == grid_width-1 || cell_y == 0 || cell_y == grid_height-1) {
            touches_edge = true;
        }
        
        var directions = [[1,0], [-1,0], [0,1], [0,-1]];
        
        for (var i = 0; i < array_length(directions); i++) {
            var dir = directions[i];
            var new_x = cell_x + dir[0];
            var new_y = cell_y + dir[1];
            
            // Look for CONNECTED UNWALKABLE cells (grid[new_x][new_y] = true)
            if (new_x >= 0 && new_x < grid_width && new_y >= 0 && new_y < grid_height &&
                grid[new_x][new_y] != "free" && !visited[new_x][new_y]) {
                
                visited[new_x][new_y] = true;
                array_push(queue, [new_x, new_y]);
            }
        }
    }
    
    return touches_edge;
}


function destroy_circle_area(center_x, center_y, radius) { // and fill edge with rocks
    var grid_radius = ceil(radius / MAP.collision_grid_cell_size);
    var center_grid_x = floor(center_x / MAP.collision_grid_cell_size);
    var center_grid_y = floor(center_y / MAP.collision_grid_cell_size);
    
    for (var dx = -grid_radius; dx <= grid_radius; dx++) {
        for (var dy = -grid_radius; dy <= grid_radius; dy++) {
            var grid_x = center_grid_x + dx;
            var grid_y = center_grid_y + dy;
            
            if (is_valid_grid_cell(grid_x, grid_y)) {
                
                // Check if this grid cell is within the circle
                var world_x = grid_x * MAP.collision_grid_cell_size + MAP.collision_grid_cell_size / 2;
                var world_y = grid_y * MAP.collision_grid_cell_size + MAP.collision_grid_cell_size / 2;
                if (point_distance(center_x, center_y, world_x, world_y) <= radius) {
                    MAP.collision_grid[grid_x][grid_y] = "free";
					if (MAP.assets_grid[grid_x][grid_y] != undefined) {
						MAP.assets_grid[grid_x][grid_y].clear();
						MAP.assets_grid[grid_x][grid_y] = undefined;
					}
                }
            }
        }
    }
	
	// now make rocks to cover outside map area
	grid_radius += 1;
	radius += MAP.collision_grid_cell_size;
	gpu_set_blendmode(bm_subtract);
	for (var dx = -grid_radius; dx <= grid_radius; dx++) {
        for (var dy = -grid_radius; dy <= grid_radius; dy++) {
            var grid_x = center_grid_x + dx;
            var grid_y = center_grid_y + dy;
            
            if (is_valid_grid_cell(grid_x, grid_y)) {
                
                // Check if this grid cell is within the circle
                var world_x = grid_x * MAP.collision_grid_cell_size + MAP.collision_grid_cell_size / 2;
                var world_y = grid_y * MAP.collision_grid_cell_size + MAP.collision_grid_cell_size / 2;
                if (point_distance(center_x, center_y, world_x, world_y) <= radius) {
                    if (MAP.collision_grid[grid_x][grid_y] == "outside" || MAP.collision_grid[grid_x][grid_y] == "island") {
						var edge = MAP.collision_grid[grid_x][grid_y] == "outside" ? true : false;
						MAP.collision_grid[grid_x][grid_y] = "edge";
						var cell = MAP.collision_grid_cell_size;
						MAP.assets_grid[grid_x][grid_y] = create_rock(grid_x*cell +cell/2, grid_y*cell+cell/2, grid_x, grid_y, MAP.dungeon_rocks[irandom(array_length(MAP.dungeon_rocks)-1)], edge);
					}
					var cell = MAP.collision_grid_cell_size;
					var fx = grid_x*cell;
					var fy = grid_y*cell;
					// Find which surface this point belongs to
					var surface_x = floor(fx / MAP.background_surface_size);
					var surface_y = floor(fy / MAP.background_surface_size);
					var surf_index = find_bg_surf_index(fx, fy);
					surface_set_target(MAP.background_fog_surfaces[surf_index]);
					draw_sprite(fog_cell, 0, fx-surface_x*MAP.background_surface_size, fy-surface_y*MAP.background_surface_size);
					surface_reset_target();
                }
            }
        }
    }
	gpu_set_blendmode(bm_normal);
	// pad new edges
	pad_edges_area(center_grid_x-grid_radius, center_grid_y-grid_radius, center_grid_x+grid_radius, center_grid_y+grid_radius);
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
        
        var node = new map_node(node_x, node_y, true);
        
        array_push(nodes, node);
		node.path_color = calculate_path_color(node, nodes);
        
        // Connect to previous trunk node (if not first node)
        if (i > 0) {
            array_push(nodes[i-1].connections, i);
            array_push(nodes[i].connections, i-1);
        }
        
        current_x = node_x;
        current_y = node_y;
    }
	nodes[array_length(nodes)-1].is_end = true;
    
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
        
        var new_node = new map_node(branch_x, branch_y, false);
		new_node.path_color = calculate_path_color(new_node, nodes);
		
        var new_index = array_length(nodes);
        array_push(nodes, new_node);
        
        // Connect to previous node in branch
        array_push(nodes[last_index].connections, new_index);
        array_push(nodes[new_index].connections, last_index);
        
        last_index = new_index;
    }
	
	nodes[array_length(nodes)-1].is_last = true;
}

function calculate_path_color(node, nodes) {
	if (!is_array(nodes) && array_length(nodes) == 0) return .45;
	// Calculate distance from start (you might want to use actual path distance)
    var dist = point_distance(node.x, node.y, nodes[0].x, nodes[0].y);
    var max_dist = point_distance(0, 0, room_width, room_height)/2;
        
    // Create color gradient: dark -> light -> dark
    var t = (sin(dist / max_dist * 2 * pi) + 1) / 2; // Sine wave for smooth transitions
    return make_color_hsv(0, 0, lerp(.35, .5, t)*255);
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

function map_node(_x, _y, _is_trunk) constructor {
	x = _x;
	y = _y;
	is_trunk = _is_trunk;
	is_last = false;
	is_end = false;
	connections = [];
	seed = irandom(9999);
	path_color = 0;
}

function find_closest_node(_x, _y) {
	var dist = MAP.size*TILE*2;
	var node = undefined;
	for (var i=0; i<array_length(MAP.map_nodes); i++) {
		var new_dist = point_distance(_x, _y, MAP.map_nodes[i].x, MAP.map_nodes[i].y);
		if (new_dist < dist) {
			dist = new_dist;
			node = MAP.map_nodes[i];
		}
	}
	return node;
}

#endregion

#region assets

function static_asset(_x, _y, _grid_x, _grid_y, _type) constructor {
	x = _x;
	y = _y;
	grid_x = _grid_x;
	grid_y = _grid_y;
    type = _type;
    sprite_index = undefined;
	image_index = 0;
	image_speed = 1/60;
	xscale = 1;
	yscale = 1;
	scale = 1;
	color = c_white;
	alpha = 1;
	update_function = undefined;
	destroy_function = undefined;
	destroyed = false;
	
    static draw = function(_x = x, _y = y, _scale=scale) {
        draw_sprite_ext(sprite_index, image_index, _x, _y, _scale*xscale, _scale*yscale, 0, color, alpha);
		image_index += image_speed;
		if (image_index > sprite_get_number(sprite_index)) image_index = 0;
    }
	static update = function() {
		if (update_function != undefined) update_function(self);
	}
	static clear = function(_array=MAP.static_assets) {
		if (_array == MAP.static_assets) {
			MAP.static_assets[grid_x][grid_y] = undefined;
			unpad_edges_cell(grid_x, grid_y);
		} else {
			var _f = function(_element, _index) {
				return (_element == self);
			}
			var _index = array_find_index(_array, _f);
			if (_index != -1) {
				array_delete(_array, _index, 1);
			}
		}
		if (destroy_function != undefined and !destroyed) {
			destroyed = true;
			destroy_function(self);
		}
	}
}

function place_edge_walls() {
	var cell = MAP.collision_grid_cell_size;
	// loop through edge of map and place walls if there is walkable cells
	for (var i=0; i<array_length(MAP.collision_grid); i++) {
		if (MAP.collision_grid[i][0] == "free") {
			MAP.collision_grid[i][0] = "edge";
			create_wall(i*cell+cell/2, cell, "horizontal", i, 0, []);
		}
		if (MAP.collision_grid[i][MAP.collision_grid_size-1] == "free") {
			MAP.collision_grid[i][MAP.collision_grid_size-1] = "edge";
			create_wall(i*cell+cell/2, (MAP.collision_grid_size-1)*cell + cell/2, "horizontal", i, MAP.collision_grid_size-1, []);
		}
	}
	for (var i=0; i<array_length(MAP.collision_grid); i++) {
		if (MAP.collision_grid[0][i] == "free") {
			MAP.collision_grid[0][i] = "edge";
			create_wall(cell/2, i*cell+cell/2, "vertical", 0, i, []);
		}
		if (MAP.collision_grid[MAP.collision_grid_size-1][i] == "free") {
			MAP.collision_grid[MAP.collision_grid_size-1][i] = "edge";
			create_wall((MAP.collision_grid_size-1)*cell + cell/2, i*cell+cell/2, "vertical", MAP.collision_grid_size-1, i, []);
		}
	}
}

function place_rocks_simple(_type) {
    
	
    // Define rock sizes and how many can fit in one cell
	switch (_type) {
		case "dungeon":
		    var rock_types = MAP.dungeon_rocks;
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
            if (MAP.collision_grid[i][j] != "free") {
                // Check all 8 surrounding cells
                for (var dx = -1; dx <= 1; dx++) {
                    for (var dy = -1; dy <= 1; dy++) {
                        var check_x = i + dx;
                        var check_y = j + dy;
                        
                        // If we find a blocked cell next to a walkable cell, place rock
                        if (check_x >= 0 && check_x < array_length(MAP.collision_grid) &&
                            check_y >= 0 && check_y < array_length(MAP.collision_grid[check_x]) &&
                            MAP.collision_grid[check_x][check_y] == "free") {
                            
                            var rock_x = i * grid_size + grid_size / 2;
                            var rock_y = j * grid_size + grid_size / 2;
                            
							if (MAP.assets_grid[i][j] == undefined) {
								var edge = is_collision_shape_edge(MAP.collision_grid, i, j).is_edge;
								MAP.assets_grid[i][j] = create_rock(rock_x, rock_y, i, j, rock_types[irandom(array_length(rock_types)-1)], edge);
							}
							break; // Only need one rock per edge cell
                        }
                    }
                }
            }
        }
    }
}
function create_rock(_x, _y, _grid_x, _grid_y, rock_type, _edge) {
    
	var _yy = _y;
	var cell = MAP.collision_grid_cell_size;
	if (is_position_walkable(_x, _y-cell)) {
		if(flag_at_position(_x, _y+cell, MAP.collision_grid) != "free") _yy += cell;
	}
	
	var _scale = _edge ? random_range(1, 1.5) : random_range(.5, 1.25);
	var rock = new static_asset(_x, _yy, _grid_x, _grid_y, "rock");
	rock.scale = _scale;
	rock.sprite_index = rock_type.sprite;
	rock.xscale = choose(-1, 1);
    
    //array_push(MAP.static_assets, rock);
	insert_static_asset(rock);
	
	// flag collision grid
	MAP.collision_grid[_grid_x][_grid_y] = "edge";
	
    return rock;
}

function insert_static_asset(asset) {
	MAP.static_assets[asset.grid_x][asset.grid_y] = asset;
}

function place_connected_walls() {
    var grid_size = MAP.collision_grid_cell_size;
    
    // Try to grow walls from existing rocks
    var walls_placed = 0;
    var max_walls = MAP.size*3 + irandom(MAP.size*3);
    
    // Shuffle rocks to start from random positions
	var statics = [];
	for (var i=0; i<array_length(MAP.static_assets); i++) {
		for (var j=0;j<array_length(MAP.static_assets[i]); j++) {
			if (MAP.static_assets[i][j] != undefined) array_push(statics, MAP.static_assets[i][j]);
		}
	}
    var shuffled_rocks = array_shuffle(statics);
    
    for (var i = 0; i < array_length(shuffled_rocks); i++) {
		if (walls_placed >= max_walls) break;
        var rock = shuffled_rocks[i];
        var grid_x = floor(rock.x / grid_size);
        var grid_y = floor(rock.y / grid_size);
        
        // Try to grow a wall from this rock position
        var wall_grown = grow_wall_from_rock(grid_x, grid_y, MAP.size + irandom(MAP.size), shuffled_rocks); // wall max length
        
        if (wall_grown>0) {
            walls_placed += wall_grown;
        }
    }
	DEBUG.add($"{walls_placed} walls placed", c_lime);
}

function grow_wall_from_rock(start_grid_x, start_grid_y, max_length, _shuffled_array) {
    var grid_size = MAP.collision_grid_cell_size;
    var walls_placed = 0;
    
	var current_x = start_grid_x;
	var current_y = start_grid_y;
    // start growing wall
    for (var i = 1; i < max_length; i++) {
		
	    // Find the best direction to grow based on nearby rocks
	    var best_dir = find_wall_direction(current_x, current_y, _shuffled_array);
		if (best_dir[0] == 0 && best_dir[1] == 0) {
			break; // No good direction found
		}
    
        var next_x = current_x + best_dir[0];
        var next_y = current_y + best_dir[1];
        
        
        // Determine wall type based on direction
        var wall_type = get_wall_type_from_direction(best_dir);
        var world_x = next_x * grid_size + grid_size / 2;
        var world_y = next_y * grid_size + grid_size / 2;
        
		
        create_wall(world_x, world_y, wall_type, next_x, next_y, _shuffled_array);
        walls_placed++;
        
        current_x = next_x;
        current_y = next_y;
    }
    
    return walls_placed;
}

function find_wall_direction(grid_x, grid_y, _shuffled_array) {
	var length = 1;
    var directions = [
        [length, 0],   // right
        [-length, 0],  // left  
        [0, length],   // down
        [0, -length],  // up
        [length, length],   // down-right
        [-length, length],  // down-left
        [length, -length],  // up-right
        [-length, -length]  // up-left
    ];
    
    var best_dir = [0, 0];
	
	directions = array_shuffle(directions);
	
    // Check each direction to see which has a rock
    for (var i = 0; i < array_length(directions); i++) {
        var dir = directions[i];
		var check_x = grid_x+dir[0];
		var check_y = grid_y+dir[1];
		// check if place is inside map
		if (check_x < 0 || check_x >= MAP.collision_grid_size) continue;
		if (check_y < 0 || check_y >= MAP.collision_grid_size) continue;
        if (is_rock_at_grid(check_x, check_y)) {
			best_dir = dir;
			break;
		}
    }
	// look again but this time 1 extra length
	if (best_dir[0] == 0 && best_dir[1] == 0) {
		for (var i = 0; i < array_length(directions); i++) {
	        var dir = directions[i];
			dir[0] = dir[0]*2;
			dir[1] = dir[1]*2;
			var check_x = grid_x+dir[0];
			var check_y = grid_y+dir[1];
			// check if place is inside map
			if (check_x < 0 || check_x >= MAP.collision_grid_size) continue;
			if (check_y < 0 || check_y >= MAP.collision_grid_size) continue;
	        if (is_rock_at_grid(check_x, check_y)) {
				best_dir = dir;
				break;
			}
	    }
	}
    
    return best_dir;
}


function is_rock_at_grid(grid_x, grid_y) {
    return (MAP.assets_grid[grid_x][grid_y] != undefined && MAP.assets_grid[grid_x][grid_y].type == "rock");
}

function create_wall(_x, _y, _type, grid_x, grid_y, _array) {
	var _yy = _y;
	
    var wall = new static_asset(_x, _yy, grid_x, grid_y, "wall");
	wall.sprite_index = get_wall_sprite(_type);
    
    insert_static_asset(wall);
	
    MAP.assets_grid[grid_x][grid_y] = wall;
}

function get_wall_type_from_direction(_direction) {
    var dx = _direction[0];
    var dy = _direction[1];
    
    if (dx != 0 && dy == 0) return "horizontal";   // Left/Right
    if (dx == 0 && dy != 0) return "vertical";     // Up/Down
    if (dx != 0 && dy != 0) return "diagonal";     // Diagonal
    
    return "horizontal"; // Default
}
function get_wall_sprite(type) {
    switch (type) {
        case "horizontal": return dungeon_wall_0_block;
        case "vertical":   return dungeon_wall_90_block;
        case "diagonal":   return dungeon_wall_45_block;
        default:           return dungeon_wall_0_block;
    }
}


function pad_edges() {
	
	var grid = MAP.collision_grid;
	for (var i=0;i<array_length(MAP.collision_grid); i++) {
		for (var j=0;j<array_length(MAP.collision_grid[i]); j++) {
			if (MAP.collision_grid[i][j] == "edge") {
				if (is_valid_grid_cell(i-1, j) && grid[i-1][j] == "free") grid[i-1][j] = "blocked";
				if (is_valid_grid_cell(i+1, j) && grid[i+1][j] == "free") grid[i+1][j] = "blocked";
				if (is_valid_grid_cell(i, j-1) && grid[i][j-1] == "free") grid[i][j-1] = "blocked";
				if (is_valid_grid_cell(i, j+1) && grid[i][j+1] == "free") grid[i][j+1] = "blocked";
			}
		}
	}
	
}

function unpad_edges_cell(grid_x, grid_y) {
	
	var grid = MAP.collision_grid;
	if (is_valid_grid_cell(grid_x-1, grid_y) && MAP.assets_grid[grid_x-1][grid_y] == undefined && grid[grid_x-1][grid_y] == "blocked") grid[grid_x-1][grid_y] = "free";
	if (is_valid_grid_cell(grid_x+1, grid_y) && MAP.assets_grid[grid_x+1][grid_y] == undefined && grid[grid_x+1][grid_y] == "blocked") grid[grid_x+1][grid_y] = "free";
	if (is_valid_grid_cell(grid_x, grid_y-1) && MAP.assets_grid[grid_x][grid_y-1] == undefined && grid[grid_x][grid_y-1] == "blocked") grid[grid_x][grid_y-1] = "free";
	if (is_valid_grid_cell(grid_x, grid_y+1) && MAP.assets_grid[grid_x][grid_y+1] == undefined && grid[grid_x][grid_y+1] == "blocked") grid[grid_x][grid_y+1] = "free";
	
}

function pad_edges_area(x1, y1, x2, y2) {
	
	var grid = MAP.collision_grid;
	var grid_width = array_length(grid);
    var grid_height = array_length(grid[0]);
    
    // Clamp coordinates to grid bounds
    var start_x = clamp(x1, 0, grid_width - 1);
    var start_y = clamp(y1, 0, grid_height - 1);
    var end_x = clamp(x2+1, 0, grid_width);
    var end_y = clamp(y2+1, 0, grid_height);
	
	for (var i=start_x; i<end_x; i++) {
		for (var j=start_y; j<end_y; j++) {
			if (grid[i][j] == "edge") {
				if (is_valid_grid_cell(i-1, j) && grid[i-1][j] == "free") grid[i-1][j] = "blocked";
				if (is_valid_grid_cell(i+1, j) && grid[i+1][j] == "free") grid[i+1][j] = "blocked";
				if (is_valid_grid_cell(i, j-1) && grid[i][j-1] == "free") grid[i][j-1] = "blocked";
				if (is_valid_grid_cell(i, j+1) && grid[i][j+1] == "free") grid[i][j+1] = "blocked";
			}
		}
	}
}

#endregion


#region background asset surfaces

function generate_background_surfaces() {
	MAP.surfaces_per_row = MAP.size*TILE/MAP.background_surface_size;
	var surface_count = power(MAP.surfaces_per_row, 2);
	// generate new surfaces
	MAP.background_surfaces = [];
	var cell = MAP.collision_grid_cell_size;
	for (var i=0; i<surface_count; i++) {
		var surf = surface_create(MAP.background_surface_size, MAP.background_surface_size);
			
		var _x = (i % MAP.surfaces_per_row) * MAP.background_surface_size;
		var _y = (i div MAP.surfaces_per_row) * MAP.background_surface_size;
		var start_x = to_grid(_x, cell);
		var start_y = to_grid(_y, cell);
			
		surface_set_target(surf);
		draw_clear_alpha(c_black, 0);
		for (var j=0; j<array_length(MAP.assets_grid); j++) {
			for (var k=0; k<array_length(MAP.assets_grid[i]); k++) {
				if (MAP.assets_grid[j][k] != undefined && MAP.assets_grid[j][k].type == "path") {
					var col = find_closest_node(j*cell, k*cell).path_color;
					draw_sprite_ext(choose(dungeon_path__1_, dungeon_path__2_, dungeon_path__3_, dungeon_path__4_, dungeon_path__5_,
					dungeon_path__6_, dungeon_path__7_, dungeon_path__8_, dungeon_path__9_, dungeon_path__10_, dungeon_path__11_), 0, j*cell-start_x*cell, k*cell-start_y*cell,
					random_range(1.15, 2.5), random_range(1.15, 2.5), irandom(360), col, 1);
				}
			}
		}
			
		surface_reset_target();
			
		array_push(MAP.background_surfaces, surf);
	}
	
	// clean up background assets from grid
	for (var j=0; j<array_length(MAP.assets_grid); j++) {
		for (var k=0; k<array_length(MAP.assets_grid[i]); k++) {
			if (MAP.assets_grid[j][k] != undefined && MAP.assets_grid[j][k].type == "path") {
				MAP.assets_grid[j][k] = undefined;
			}
		}
	}
	
}

function draw_background_surfaces() {
	for (var i=0; i<array_length(MAP.background_surfaces); i++) {
		if (!surface_exists(MAP.background_surfaces[i])) {
			generate_background_surfaces();
			break;
		}
		var _x = (i % MAP.surfaces_per_row) * MAP.background_surface_size;
		var _y = (i div MAP.surfaces_per_row) * MAP.background_surface_size;
		draw_surface(MAP.background_surfaces[i], _x, _y);
	}
}

function find_bg_surf_index(_x, _y) {
	// Find which surface this point belongs to
	var surface_x = floor(_x / MAP.background_surface_size);
	var surface_y = floor(_y / MAP.background_surface_size);
	return surface_y * MAP.surfaces_per_row + surface_x;
}

#endregion


#region more assets

function place_main_assets() {
	
	// place pillars
	for (var i=0; i<array_length(MAP.map_nodes); i++) {
		if (MAP.map_nodes[i].is_last) {
			instance_create_layer(MAP.map_nodes[i].x, MAP.map_nodes[i].y, "Instances", o_dungeon_pillar, {image_xscale : 1});
		}
	}
	
	instance_create_layer(MAP.map_nodes[1].x, MAP.map_nodes[1].y, "Instances", o_dungeon_campfire, {image_xscale : 1});
	
}



#endregion