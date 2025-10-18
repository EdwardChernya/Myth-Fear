// script goes brrrrrr
function enemy() constructor {
	
	array_push(MAP.dynamic_assets, self);
	
	// init
	position = new Vector2();
	prev_position = new Vector2();
	
	grid_position = new Vector2();
	prev_grid_position = new Vector2();
	prev_move_vector = undefined;
	move_vector_skip = 1;
	
	visible = true;
	stats = new stat_struct();
	
	#region states
	
	idle = new ai_idle_state(self);
	move = new ai_move_state(self);
	aattack = new ai_aattack_state(self);
	
	state = idle;
	state_buffer = undefined;
	
	destroy_function = undefined;
	destroyed = false;
	
	
	#endregion
	
	sprite_index = dungeon_skeleton_idle;
	image_index = 0;
	image_speed = 1/60;
	image_xscale = choose(1, -1);
	image_yscale = 1;
	image_alpha = 1;
	animations = new animations_struct();
	
	cctimer = 0;
	
	// enemy specific
	in_combat = 0;
	aggro_range = 125;
	leash_range = aggro_range*3;
	
	
	static update_begin = function() {
		
	}
	static update = function() {
		
		stats.update();
		
		// state stuff
		state.update();
		
		if (in_combat > 0) in_combat -= 1;
		
		if (state.animation_ended()) {
			if (state_buffer != undefined) {
				force_state(state_buffer);
				state_buffer = undefined;
			} else {
				change_state(idle);
			}
		}
	}
	static update_end = function() {
		
	}
	
	static draw = function() {
		if ((MAP.fog_grid[grid_position.x][grid_position.y] == "fog" || MAP.fog_grid[grid_position.x][grid_position.y] == "revealed") && !DEV) return;
		state.draw();
	}
	
	// state stuff
	static change_state = function(_state) {
		if (state.can_force) {
			state.exit_state();
			state = _state;
			state.enter_state();
		} else {
			state_buffer = _state;
		}
	}
	static force_state = function(_state) {
		state.exit_state();
		state = _state;
		state.enter_state();
	}
	
	static destroy = function() {
		if (destroy_function != undefined and !destroyed) {
			destroyed = true;
			destroy_function(self);
		}
		clear(MAP.dynamic_assets);
	}
	static clear = function(array) {
		var _f = function(_element, _index) {
			return (_element == self);
		}
		var _index = array_find_index(array, _f);
		if (_index != -1) {
			array_delete(array, _index, 1);
		}
	}
}


#region ai basic states
function ai_idle_state(_parent) : state_struct(_parent) constructor {
	
	parent = _parent;
	name = "idle";
	
	looping = true;
	can_force = true;
	
	enter_function = function(_self) {
		with (_self) {
			parent.sprite_index = parent.animations.idle;
			parent.image_speed = 1/60;
			parent.prev_move_vector = undefined;
			
		}
	}
	update_function = function(_self) {
		with (_self) {
			parent.grid_position.Set(to_grid(parent.position.x), to_grid(parent.position.y));
			parent.prev_grid_position.Set(parent.grid_position);
			if (MAP.dynamic_grid[parent.grid_position.x][parent.grid_position.y] == undefined) MAP.dynamic_grid[parent.grid_position.x][parent.grid_position.y] = parent;
			var range = parent.in_combat>0 ? parent.leash_range : parent.aggro_range;
			if (point_in_ellipse(parent.position.x, parent.position.y, PLAYER.position.x, PLAYER.position.y, range, .67)) {
				with (parent) change_state(move);
			}
		}
	}
}
function ai_move_state(_parent) : state_struct(_parent) constructor {
	parent = _parent;
	name = "move";
	looping = true;
	can_force = true;
	image_speed = 4/60;
	enter_function = function(_self) {
		with (_self) {
			parent.sprite_index = parent.animations.move;
			parent.image_speed = image_speed;
		}
	}
	update_function = function(_self) {
		with (_self) {
			move_with_flow_field_ai(parent);
			if (parent.position.Distance(parent.prev_position) < .2) {
				parent.sprite_index = parent.animations.idle;
			} else {
				parent.sprite_index = parent.animations.move;
			}
			parent.prev_position.Set(parent.position);
			
			var dis = point_distance(parent.position.x, parent.position.y, PLAYER.position.x, PLAYER.position.y);
			if (dis < parent.stats.arange) {
				with (parent) change_state(aattack);
			}
			if (dis > parent.leash_range && parent.in_combat <= 0) with (parent) change_state(idle);
			
		}
	}
}
function ai_aattack_state(_parent) : state_struct(_parent) constructor {
	
	parent = _parent;
	name = "aattack";
	can_force = true;
	image_speed = 6/60;
	
	enter_function = function(_self) {
		with (_self) {
			parent.sprite_index = parent.animations.aattack;
			parent.image_speed = image_speed;
			
		}
	}
	update_function = function(_self) {
		with (_self) {
			xscale_to_target(parent, PLAYER.position);
			var dis = point_distance(parent.position.x, parent.position.y, PLAYER.position.x, PLAYER.position.y);
			if (!code_ended() && dis > parent.stats.arange*1.5) with (parent) change_state(move);
			if (code_ended() && !code_ran) {
				//new reward_trail_particle(parent.position.x, parent.position.y-32, c_fuchsia, c_blue);
				code_ran = true;
			}
			if (animation_ended() && dis < parent.stats.arange) with (parent) change_state(aattack);
			parent.in_combat = IN_COMBAT;
		}
	}
}

#endregion


#region pathfinding

function update_flow_field_fast() {
    
    var time = get_timer();
	
	PLAYER.flow_field_timer = PLAYER.flow_field_delay;
	
	#region init
    var grid_size = MAP.collision_grid_cell_size;
    var width = array_length(MAP.collision_grid);
    var height = array_length(MAP.collision_grid[0]);
    var target_grid_x = floor(PLAYER.position.x / grid_size);
    var target_grid_y = floor(PLAYER.position.y / grid_size);
    var center_grid_x = floor(PLAYER.position.x / grid_size);
    var center_grid_y = floor(PLAYER.position.y / grid_size);
    
    // Calculate region bounds
    var region_size = 10;
    var start_x = max(0, center_grid_x - region_size);
    var end_x = min(width - 1, center_grid_x + region_size);
    var start_y = max(0, center_grid_y - region_size);
    var end_y = min(height - 1, center_grid_y + region_size);
    
    // Use a larger cost calculation area
    var cost_region = region_size + 2;
    
    var cost_start_x = max(0, center_grid_x - cost_region);
    var cost_end_x = min(width - 1, center_grid_x + cost_region);
    var cost_start_y = max(0, center_grid_y - cost_region);
    var cost_end_y = min(height - 1, center_grid_y + cost_region);
    
	#endregion
	
    // FAST BFS with all 8 directions
    var queue = ds_queue_create();
    
    // Reset costs only in the cost region
    for (var xx = cost_start_x; xx <= cost_end_x; xx++) {
        for (var yy = cost_start_y; yy <= cost_end_y; yy++) {
            MAP.cost_field[xx][yy] = 9999;
        }
    }
    
    // Start from target
    MAP.cost_field[target_grid_x][target_grid_y] = 0;
    ds_queue_enqueue(queue, [target_grid_x, target_grid_y]);
    
    // Use all 8 directions but with integer costs for speed
    var dirs = [
        [1,0, 10],    // right - cost 10
        [-1,0, 10],   // left - cost 10  
        [0,1, 10],    // down - cost 10
        [0,-1, 10],   // up - cost 10
        [1,1, 14],    // down-right - cost ~14 (sqrt(2) ≈ 1.414 * 10)
        [-1,1, 14],   // down-left - cost ~14
        [1,-1, 14],   // up-right - cost ~14
        [-1,-1, 14]   // up-left - cost ~14
    ];
    
    while (!ds_queue_empty(queue)) {
        var cell = ds_queue_dequeue(queue);
        var xx = cell[0], yy = cell[1];
        var current_cost = MAP.cost_field[xx][yy];
        
        for (var i = 0; i < 8; i++) {
            var dir = dirs[i];
            var nx = xx + dir[0], ny = yy + dir[1];
            
            if (nx >= cost_start_x && nx <= cost_end_x && 
                ny >= cost_start_y && ny <= cost_end_y && 
                MAP.collision_grid[nx][ny] == "free") {
                
                var new_cost = current_cost + dir[2];
                
                if (new_cost < MAP.cost_field[nx][ny]) {
                    MAP.cost_field[nx][ny] = new_cost;
                    ds_queue_enqueue(queue, [nx, ny]);
                }
            }
        }
    }
    
    ds_queue_destroy(queue);
    
    // FAST flow direction generation with diagonals
    for (var xx = start_x; xx <= end_x; xx++) {
        for (var yy = start_y; yy <= end_y; yy++) {
            if (MAP.collision_grid[xx][yy] == "free") {
				if (!is_cell_in_area(xx, yy, target_grid_x-1, target_grid_y-1, target_grid_x+1, target_grid_y+1)) {
					if (((xx >= target_grid_x-1) && (xx <= target_grid_x+1)) || ((yy >= target_grid_y-1) && (yy <= target_grid_y+1))) {
						var new_dir = new Vector2(xx, yy);
						new_dir.to_target(target_grid_x, target_grid_y);
						new_dir.Normalize();
						new_dir.Round();
						if (is_valid_grid_cell(xx+new_dir.x, yy+new_dir.y) && MAP.collision_grid[xx+new_dir.x][yy+new_dir.y] == "free") {
							MAP.flow_field[xx][yy].Set(new_dir);
							continue;
						}
					}
				}
				
                var best_dir_x = 0;
                var best_dir_y = 0;
                var best_cost = MAP.cost_field[xx][yy];
                var found_better = false;
                
                // Check all 8 neighbors
                var neighbors = [
                    [xx-1, yy-1, -1, -1], [xx, yy-1, 0, -1], [xx+1, yy-1, 1, -1],
                    [xx-1, yy,   -1, 0],                     [xx+1, yy,   1, 0],
                    [xx-1, yy+1, -1, 1],  [xx, yy+1, 0, 1],  [xx+1, yy+1, 1, 1]
                ];
                
                for (var i = 0; i < 8; i++) {
                    var neighbor = neighbors[i];
                    var nx = neighbor[0], ny = neighbor[1];
                    var dir_x = neighbor[2], dir_y = neighbor[3];
                    
                    if (nx >= 0 && nx < width && ny >= 0 && ny < height && 
                        MAP.collision_grid[nx][ny] == "free") {
                        
                        if (MAP.cost_field[nx][ny] < best_cost) {
                            best_cost = MAP.cost_field[nx][ny];
                            best_dir_x = dir_x;
                            best_dir_y = dir_y;
                            found_better = true;
                        }
                    }
                }
                
                // Fallback: if no better neighbor, point toward target
                if (!found_better && MAP.cost_field[xx][yy] < 9999) {
                    var dx = target_grid_x - xx;
                    var dy = target_grid_y - yy;
                    
                    // Simple normalization for diagonals
                    if (abs(dx) > 0 && abs(dy) > 0) {
                        best_dir_x = sign(dx);
                        best_dir_y = sign(dy);
                    } else if (abs(dx) > abs(dy)) {
                        best_dir_x = sign(dx);
                        best_dir_y = 0;
                    } else {
                        best_dir_x = 0;
                        best_dir_y = sign(dy);
                    }
                }
                
                MAP.flow_field[xx][yy].Set(best_dir_x, best_dir_y);
            } else {
                MAP.flow_field[xx][yy].Set(0, 0);
            }
        }
    }
    
    var new_time = get_timer()-time;
    // capture time taken
    //DEBUG.add($"{new_time/1000}ms", c_fuchsia);
}
function is_cell_in_area(cx, cy, x1, y1, x2, y2) {
	return (cx >= x1 && cy >= y1 && cx <= x2 && cy <= y2);
}

function update_flow_field() {
	
	static ppos = new Vector2(to_grid(PLAYER.position.x), to_grid(PLAYER.position.y));
	var pos = new Vector2(to_grid(PLAYER.position.x), to_grid(PLAYER.position.y));
	if (pos.x == ppos.x && pos.y == ppos.y) return;
	ppos.Set(pos);
	
	var time = get_timer();
	
	var grid_size = MAP.collision_grid_cell_size;
    var width = array_length(MAP.collision_grid);
    var height = array_length(MAP.collision_grid[0]);
	var target_grid_x = to_grid(PLAYER.position.x);
	var target_grid_y = to_grid(PLAYER.position.y);
	var size = 10;
	var start_x = clamp(target_grid_x-size, 0, width);
	var start_y = clamp(target_grid_y-size, 0, width);
	var end_x   = clamp(target_grid_x+size, 0, width);
	var end_y   = clamp(target_grid_y+size, 0, width);
	var cost_start_x = clamp(target_grid_x-(size+2), 0, width);
	var cost_start_y = clamp(target_grid_y-(size+2), 0, width);
	var cost_end_x   = clamp(target_grid_x+(size+2), 0, width);
	var cost_end_y   = clamp(target_grid_y+(size+2), 0, width);
	
	 // Reset cost field
    for (var xx = cost_start_x; xx < cost_end_x; xx++) {
        for (var yy = cost_start_y; yy < cost_end_y; yy++) {
            MAP.cost_field[xx][yy] = 9999;
        }
    }
	
	
    // BFS from target to update costs in the larger area
    var queue = [];
    MAP.cost_field[target_grid_x][target_grid_y] = 0;
    array_push(queue, [target_grid_x, target_grid_y, 0]);
    
    var directions = [
        [1,0, 1],    // right
        [-1,0, 1],   // left  
        [0,1, 1],    // down
        [0,-1, 1],   // up
        [1,1, 1.414], // down-right
        [-1,1, 1.414], // down-left
        [1,-1, 1.414], // up-right
        [-1,-1, 1.414]  // up-left
    ];
    
    while (array_length(queue) > 0) {
        var cell = queue[0];
        array_delete(queue, 0, 1);
        var xx = cell[0], yy = cell[1], cost = cell[2];
        
        for (var i = 0; i < array_length(directions); i++) {
            var dir = directions[i];
            var nx = xx + dir[0], ny = yy + dir[1];
            
            if (nx >= cost_start_x && nx <= cost_end_x && 
                ny >= cost_start_y && ny <= cost_end_y && 
                MAP.collision_grid[nx][ny] == "free") {
                
                var new_cost = cost + dir[2];
                
                if (new_cost < MAP.cost_field[nx][ny]) {
                    MAP.cost_field[nx][ny] = new_cost;
                    array_push(queue, [nx, ny, new_cost]);
                }
            }
        }
    }
    
    // Add small noise to cost field in the update region
    for (var xx = start_x; xx <= end_x; xx++) {
        for (var yy = start_y; yy <= end_y; yy++) {
            if (MAP.collision_grid[xx][yy] == "free" && MAP.cost_field[xx][yy] < 9999) {
                MAP.cost_field[xx][yy] += random_range(-0.2, 0.2);
            }
        }
    }
    
    // Generate flow directions only in the specified region
    var simple_directions = [[1,0], [-1,0], [0,1], [0,-1], [1,1], [-1,1], [1,-1], [-1,-1]];
    
    for (var xx = start_x; xx <= end_x; xx++) {
        for (var yy = start_y; yy <= end_y; yy++) {
            if (MAP.collision_grid[xx][yy] == "free" && MAP.cost_field[xx][yy] < 9999) {
                var candidates = [];
                var current_cost = MAP.cost_field[xx][yy];
                
                // Find all valid neighbors with lower cost
                for (var i = 0; i < array_length(simple_directions); i++) {
                    var dir = simple_directions[i];
                    var nx = xx + dir[0], ny = yy + dir[1];
                    
                    // Check if neighbor is within the larger cost calculation area
                    if (nx >= cost_start_x && nx <= cost_end_x && 
                        ny >= cost_start_y && ny <= cost_end_y && 
                        MAP.collision_grid[nx][ny] == "free" &&
                        MAP.cost_field[nx][yy] < current_cost) {
                        
                        array_push(candidates, {
                            dir: dir,
                            cost: MAP.cost_field[nx][ny],
                            is_cardinal: (abs(dir[0]) + abs(dir[1]) == 1)
                        });
                    }
                }
                
                if (array_length(candidates) > 0) {
                    // Sort by cost (lowest first)
                    for (var i = 0; i < array_length(candidates) - 1; i++) {
                        for (var j = i + 1; j < array_length(candidates); j++) {
                            if (candidates[i].cost > candidates[j].cost) {
                                var temp = candidates[i];
                                candidates[i] = candidates[j];
                                candidates[j] = temp;
                            }
                        }
                    }
                    
                    // Get the best cost
                    var best_cost = candidates[0].cost;
                    
                    // Filter to only the best candidates (within tolerance)
                    var best_candidates = [];
                    var tolerance = 0.5;
                    
                    for (var i = 0; i < array_length(candidates); i++) {
                        if (candidates[i].cost <= best_cost + tolerance) {
                            array_push(best_candidates, candidates[i]);
                        }
                    }
                    
                    // Weight random selection
                    var chosen = best_candidates[0];
                    if (array_length(best_candidates) > 1) {
                        var weights = [];
                        var total_weight = 0;
                        
                        for (var i = 0; i < array_length(best_candidates); i++) {
                            var cand = best_candidates[i];
                            var weight = (1.0 / (cand.cost + 1)) * (cand.is_cardinal ? 2.0 : 1.0);
                            array_push(weights, weight);
                            total_weight += weight;
                        }
                        
                        var rand = random(total_weight);
                        var current = 0;
                        for (var i = 0; i < array_length(weights); i++) {
                            current += weights[i];
                            if (rand <= current) {
                                chosen = best_candidates[i];
                                break;
                            }
                        }
                    }
                    
                    MAP.flow_field[xx][yy].Set(chosen.dir[0], chosen.dir[1]);
                } else {
                    MAP.flow_field[xx][yy].Set(0);
                }
            } else {
                MAP.flow_field[xx][yy].Set(0);
            }
        }
    }
    
    // Apply light smoothing only to the update region
    smooth_flow_field_region(start_x, end_x, start_y, end_y, 1);
	
	// capture time taken
	var new_time = get_timer()-time;
	DEBUG.add($"{new_time/1000}ms", c_fuchsia);
}

function smooth_flow_field_region(start_x, end_x, start_y, end_y, passes = 1) {
    var width = array_length(MAP.flow_field);
    var height = array_length(MAP.flow_field[0]);
    
    // Adjust bounds to avoid edges
    var smooth_start_x = max(1, start_x);
    var smooth_end_x = min(width - 2, end_x);
    var smooth_start_y = max(1, start_y);
    var smooth_end_y = min(height - 2, end_y);
    
    for (var pass = 0; pass < passes; pass++) {
        // Create temporary array for new flow directions
        var new_flow = array_create(width);
        for (var xx = 0; xx < width; xx++) {
            new_flow[xx] = array_create(height);
            for (var yy = 0; yy < height; yy++) {
                new_flow[xx][yy] = new Vector2();
            }
        }
        
        // Calculate smoothed directions only in the region
        for (var xx = smooth_start_x; xx <= smooth_end_x; xx++) {
            for (var yy = smooth_start_y; yy <= smooth_end_y; yy++) {
                if (MAP.collision_grid[xx][yy] == "free") {
                    var avg_x = 0, avg_y = 0;
                    var count = 0;
                    
                    // Average with 3x3 neighborhood
                    for (var dx = -1; dx <= 1; dx++) {
                        for (var dy = -1; dy <= 1; dy++) {
                            var nx = xx + dx;
                            var ny = yy + dy;
                            if (nx >= 0 && nx < width && ny >= 0 && ny < height && 
                                MAP.collision_grid[nx][ny] == "free") {
                                avg_x += MAP.flow_field[nx][ny].x;
                                avg_y += MAP.flow_field[nx][ny].y;
                                count++;
                            }
                        }
                    }
                    
                    if (count > 0) {
                        new_flow[xx][yy].x = avg_x / count;
                        new_flow[xx][yy].y = avg_y / count;
                        
                        // Normalize the direction vector
                        var len = sqrt(new_flow[xx][yy].x * new_flow[xx][yy].x + new_flow[xx][yy].y * new_flow[xx][yy].y);
                        if (len > 0) {
                            new_flow[xx][yy].x /= len;
                            new_flow[xx][yy].y /= len;
                        }
                    }
                }
            }
        }
        
        // Apply smoothing with lerp only in the region
        for (var xx = start_x; xx <= end_x; xx++) {
            for (var yy = start_y; yy <= end_y; yy++) {
                if (MAP.collision_grid[xx][yy] == "free") {
                    MAP.flow_field[xx][yy].x = lerp(MAP.flow_field[xx][yy].x, new_flow[xx][yy].x, 0.3);
                    MAP.flow_field[xx][yy].y = lerp(MAP.flow_field[xx][yy].y, new_flow[xx][yy].y, 0.3);
                    
                    // Normalize the final direction
                    var len = sqrt(MAP.flow_field[xx][yy].x * MAP.flow_field[xx][yy].x + MAP.flow_field[xx][yy].y* MAP.flow_field[xx][yy].y);
                    if (len > 0) {
                        MAP.flow_field[xx][yy].x /= len;
                        MAP.flow_field[xx][yy].y /= len;
                    }
                }
            }
        }
    }
}


function generate_flow_field(target_x, target_y) {
    var grid_size = MAP.collision_grid_cell_size;
    var width = array_length(MAP.collision_grid);
    var height = array_length(MAP.collision_grid[0]);
    var target_grid_x = floor(target_x / grid_size);
    var target_grid_y = floor(target_y / grid_size);
    
    // Reset cost field
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy < height; yy++) {
            MAP.cost_field[xx][yy] = 9999;
        }
    }
    
    // BFS from target to all reachable cells
    var queue = [];
    MAP.cost_field[target_grid_x][target_grid_y] = 0;
    array_push(queue, [target_grid_x, target_grid_y, 0]);
    
    var directions = [
        [1,0, 1],    // right
        [-1,0, 1],   // left  
        [0,1, 1],    // down
        [0,-1, 1],   // up
        [1,1, 1.414], // down-right
        [-1,1, 1.414], // down-left
        [1,-1, 1.414], // up-right
        [-1,-1, 1.414]  // up-left
    ];
    
    while (array_length(queue) > 0) {
        var cell = queue[0];
        array_delete(queue, 0, 1);
        var xx = cell[0], yy = cell[1], cost = cell[2];
        
        for (var i = 0; i < array_length(directions); i++) {
            var dir = directions[i];
            var nx = xx + dir[0], ny = yy + dir[1];
            
            if (nx >= 0 && nx < width && ny >= 0 && ny < height && 
                MAP.collision_grid[nx][ny] == "free") {
                
                var new_cost = cost + dir[2]; // Use pre-defined costs
                
                if (new_cost < MAP.cost_field[nx][ny]) {
                    MAP.cost_field[nx][ny] = new_cost;
                    array_push(queue, [nx, ny, new_cost]);
                }
            }
        }
    }
    
    // Add small noise to cost field to break symmetry
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy < height; yy++) {
            if (MAP.collision_grid[xx][yy] == "free" && MAP.cost_field[xx][yy] < 9999) {
                MAP.cost_field[xx][yy] += random_range(-0.2, 0.2);
            }
        }
    }
    
    // Generate flow directions with weighted random tie-breaking
    var simple_directions = [[1,0], [-1,0], [0,1], [0,-1], [1,1], [-1,1], [1,-1], [-1,-1]];
    
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy < height; yy++) {
            if (MAP.collision_grid[xx][yy] == "free" && MAP.cost_field[xx][yy] < 9999) {
                var candidates = [];
                var current_cost = MAP.cost_field[xx][yy];
                
                // Find all valid neighbors with lower cost
                for (var i = 0; i < array_length(simple_directions); i++) {
                    var dir = simple_directions[i];
                    var nx = xx + dir[0], ny = yy + dir[1];
                    
                    if (nx >= 0 && nx < width && ny >= 0 && ny < height && 
                        MAP.collision_grid[nx][ny] == "free" &&
                        MAP.cost_field[nx][ny] < current_cost) {
                        
                        array_push(candidates, {
                            dir: dir,
                            cost: MAP.cost_field[nx][ny],
                            is_cardinal: (abs(dir[0]) + abs(dir[1]) == 1)
                        });
                    }
                }
                
                if (array_length(candidates) > 0) {
                    // Sort by cost (lowest first)
                    for (var i = 0; i < array_length(candidates) - 1; i++) {
                        for (var j = i + 1; j < array_length(candidates); j++) {
                            if (candidates[i].cost > candidates[j].cost) {
                                var temp = candidates[i];
                                candidates[i] = candidates[j];
                                candidates[j] = temp;
                            }
                        }
                    }
                    
                    // Get the best cost
                    var best_cost = candidates[0].cost;
                    
                    // Filter to only the best candidates (within tolerance)
                    var best_candidates = [];
                    var tolerance = 0.5; // Allow some cost variation
                    
                    for (var i = 0; i < array_length(candidates); i++) {
                        if (candidates[i].cost <= best_cost + tolerance) {
                            array_push(best_candidates, candidates[i]);
                        }
                    }
                    
                    // Weight random selection
                    var chosen = best_candidates[0];
                    if (array_length(best_candidates) > 1) {
                        var weights = [];
                        var total_weight = 0;
                        
                        for (var i = 0; i < array_length(best_candidates); i++) {
                            var cand = best_candidates[i];
                            var weight = (1.0 / (cand.cost + 1)) * (cand.is_cardinal ? 2.0 : 1.0);
                            array_push(weights, weight);
                            total_weight += weight;
                        }
                        
                        var rand = random(total_weight);
                        var current = 0;
                        for (var i = 0; i < array_length(weights); i++) {
                            current += weights[i];
                            if (rand <= current) {
                                chosen = best_candidates[i];
                                break;
                            }
                        }
                    }
                    
                    MAP.flow_field[xx][yy].Set(chosen.dir[0], chosen.dir[1]);
                } else {
                    MAP.flow_field[xx][yy].Set(0);
                }
            } else {
                MAP.flow_field[xx][yy].Set(0);
            }
        }
    }
    
    // Apply light smoothing
    smooth_flow_field(1);
}

function smooth_flow_field(passes = 1) {
    var width = array_length(MAP.flow_field);
    var height = array_length(MAP.flow_field[0]);
    
    for (var pass = 0; pass < passes; pass++) {
        // Create temporary array for new flow directions
        var new_flow = array_create(width);
        for (var xx = 0; xx < width; xx++) {
            new_flow[xx] = array_create(height);
            for (var yy = 0; yy < height; yy++) {
                new_flow[xx][yy] = new Vector2();
            }
        }
        
        // Calculate smoothed directions
        for (var xx = 1; xx < width - 1; xx++) {
            for (var yy = 1; yy < height - 1; yy++) {
                if (MAP.collision_grid[xx][yy] == "free") {
                    var avg_x = 0, avg_y = 0;
                    var count = 0;
                    
                    // Average with 3x3 neighborhood
                    for (var dx = -1; dx <= 1; dx++) {
                        for (var dy = -1; dy <= 1; dy++) {
                            var nx = xx + dx;
                            var ny = yy + dy;
                            if (nx >= 0 && nx < width && ny >= 0 && ny < height && 
                                MAP.collision_grid[nx][ny] == "free") {
                                avg_x += MAP.flow_field[nx][ny].x;
                                avg_y += MAP.flow_field[nx][ny].y;
                                count++;
                            }
                        }
                    }
                    
                    if (count > 0) {
                        new_flow[xx][yy].x = avg_x / count;
                        new_flow[xx][yy].y = avg_y / count;
                        
                        // Normalize the direction vector
                        var len = sqrt(new_flow[xx][yy].x * new_flow[xx][yy].x + new_flow[xx][yy].y * new_flow[xx][yy].y);
                        if (len > 0) {
                            new_flow[xx][yy].x /= len;
                            new_flow[xx][yy].y /= len;
                        }
                    }
                }
            }
        }
        
        // Apply smoothing with lerp
        for (var xx = 0; xx < width; xx++) {
            for (var yy = 0; yy < height; yy++) {
                if (MAP.collision_grid[xx][yy] == "free") {
                    MAP.flow_field[xx][yy].x = lerp(MAP.flow_field[xx][yy].x, new_flow[xx][yy].x, 0.3);
                    MAP.flow_field[xx][yy].y = lerp(MAP.flow_field[xx][yy].y, new_flow[xx][yy].y, 0.3);
                    
                    // Normalize the final direction
                    var len = sqrt(MAP.flow_field[xx][yy].x * MAP.flow_field[xx][yy].x + MAP.flow_field[xx][yy].y * MAP.flow_field[xx][yy].y);
                    if (len > 0) {
                        MAP.flow_field[xx][yy].x /= len;
                        MAP.flow_field[xx][yy].y /= len;
                    }
                }
            }
        }
    }
}


function move_with_flow_field(_struct) {
    var grid_size = MAP.collision_grid_cell_size;
    var grid_x = floor(_struct.position.x / grid_size);
    var grid_y = floor(_struct.position.y / grid_size);
    
    // Get flow direction from the grid
    var flow_dir = MAP.flow_field[grid_x][grid_y];
    
    // If no flow direction (0,0), try to find nearest valid direction
    if (flow_dir.x== 0 && flow_dir.y == 0) {
        // Look for nearest flow direction in 3x3 area
        for (var dx = -1; dx <= 1; dx++) {
            for (var dy = -1; dy <= 1; dy++) {
                var nx = grid_x + dx;
                var ny = grid_y + dy;
                if (nx >= 0 && nx < array_length(MAP.flow_field) && 
                    ny >= 0 && ny < array_length(MAP.flow_field[0])) {
                    
                    var nearby_flow = MAP.flow_field[nx][ny];
                    if (nearby_flow.x != 0 || nearby_flow.y != 0) {
                        flow_dir = nearby_flow;
                        break;
                    }
                }
            }
            if (flow_dir.x != 0 || flow_dir.y != 0) break;
        }
    }
    
    // If still no direction, don't move
    if (flow_dir.x == 0 && flow_dir.y == 0) {
		with (_struct) change_state(idle);
        return;
    }
    
    // Create movement vector from flow direction
    var move_vector = new Vector2(flow_dir);
    move_vector.Normalize(); // Ensure it's a unit vector
    
    // Use your existing collision function
    move_w_collision(move_vector, _struct);
}

function move_with_flow_field_ai(_struct) {
	
	if (_struct.prev_move_vector != undefined) {
		var move_vector = _struct.prev_move_vector;
		move_vector.Normalize(); // Ensure it's a unit vector
	    // Use your existing collision function
	    move_w_collision(move_vector, _struct);
		return;
	}
	
    var grid_size = MAP.collision_grid_cell_size;
    var grid_x = floor(_struct.position.x / grid_size);
    var grid_y = floor(_struct.position.y / grid_size);
    
    // Get flow direction from the grid
    var flow_dir = MAP.flow_field[grid_x][grid_y];
    
    // If no flow direction (0,0), try to find nearest valid direction
    if (flow_dir.x== 0 && flow_dir.y == 0) {
        // Look for nearest flow direction in 3x3 area
        for (var dx = -1; dx <= 1; dx++) {
            for (var dy = -1; dy <= 1; dy++) {
                var nx = grid_x + dx;
                var ny = grid_y + dy;
                if (is_valid_grid_cell(nx, ny)) {
                    var nearby_flow = MAP.flow_field[nx][ny];
                    if (nearby_flow.x != 0 || nearby_flow.y != 0) {
                        flow_dir = nearby_flow;
                        break;
                    }
                }
            }
            if (flow_dir.x != 0 || flow_dir.y != 0) break;
        }
    }
    
    // If still no direction, don't move
    if (flow_dir.x == 0 && flow_dir.y == 0) {
		with (_struct) change_state(idle);
        return;
    }
    
    // Create movement vector from flow direction
    var move_vector = new Vector2(flow_dir);
	// look for other directions if its blocked
	if (MAP.dynamic_grid[grid_x+move_vector.x][grid_y+move_vector.y] != undefined) {
		var angle = move_vector.to_angle();
		var check_direction = [
			move_vector.vector_array_from_angle_grid(angle+45),
			move_vector.vector_array_from_angle_grid(angle-45),
			move_vector.vector_array_from_angle_grid(angle+90),
			move_vector.vector_array_from_angle_grid(angle-90),
			move_vector.vector_array_from_angle_grid(angle+135),
			move_vector.vector_array_from_angle_grid(angle-135),
			move_vector.vector_array_from_angle_grid(angle+180)
		];
		
		var found_alternative = false;
		// Check each alternative direction in order
	    for (var i = 0; i < array_length(check_direction); i++) {
	        var alt_dir = check_direction[i];
	        var check_x = grid_x + alt_dir[0];
	        var check_y = grid_y + alt_dir[1];
        
	        // Check if this direction is walkable and not blocked
	        if (is_valid_grid_cell(check_x, check_y) &&
	            MAP.dynamic_grid[check_x][check_y] == undefined &&
	            MAP.collision_grid[check_x][check_y] == "free") {
            
	            // Found a valid alternative direction
	            move_vector.Set(alt_dir[0], alt_dir[1]);
				_struct.prev_move_vector = move_vector;
				_struct.move_vector_skip = 1;
				if ((_struct.grid_position.x == PLAYER.grid_position.x || _struct.grid_position.y == PLAYER.grid_position.y) ||
				(_struct.grid_position.x+move_vector.x == PLAYER.grid_position.x || _struct.grid_position.y+move_vector.y == PLAYER.grid_position.y)) _struct.move_vector_skip = 3;
	            found_alternative = true;
	            break;
	        }
	    }
    
	    // If no alternative found, you could add fallback behavior here
	    // For example, stop movement or try random direction
	    if (!found_alternative) {
	        // Optional: set move_vector to zero to stop movement
			//with (_struct) change_state(idle);
			return;
	    }
	}
    move_vector.Normalize(); // Ensure it's a unit vector
    
    // Use your existing collision function
    move_w_collision(move_vector, _struct);
}





#endregion



#region enemies

function skelly(_x, _y) : enemy() constructor {
	
	position.Set(_x, _y);
	
	animations.idle = dungeon_skeleton_idle;
	animations.move = dungeon_skeleton_walk;
	animations.aattack = dungeon_skeleton_attack;
	
	aattack.code_index = 3;
	
	stats.speed = 1;
	
	// enter state manually after setting up animations
	state.enter_state();
	
}

#endregion