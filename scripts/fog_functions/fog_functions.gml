// script goes brrrrrr


function generate_fog_surfaces() {
	MAP.surfaces_per_row = MAP.size*TILE/MAP.background_surface_size;
	var surface_count = power(MAP.surfaces_per_row, 2);
	
	// generate background fog surfaces
	for (var i=0; i<array_length(MAP.background_fog_surfaces); i++) {
		if (surface_exists(MAP.background_fog_surfaces[i])) surface_free(MAP.background_fog_surfaces[i]);
	}
	MAP.background_fog_surfaces = [];
	var cell = MAP.collision_grid_cell_size;
	for (var i=0; i<surface_count; i++) {
		var surf = surface_create(MAP.background_surface_size, MAP.background_surface_size);
			
		var _x = (i % MAP.surfaces_per_row) * MAP.background_surface_size;
		var _y = (i div MAP.surfaces_per_row) * MAP.background_surface_size;
			
		surface_set_target(surf);
		draw_clear_alpha(c_black, 0);
		
		var fog_width = sprite_get_width(bg_stars_256);
		var tile_n = ceil(MAP.background_surface_size/fog_width);
		// Draw tiled fog background
		for (var xx = 0; xx < tile_n; xx++) {
		    for (var yy = 0; yy < tile_n; yy++) {
		        var draw_x = xx * fog_width;
		        var draw_y = yy * fog_width;
		        draw_sprite(bg_stars_256, irandom(2), draw_x, draw_y);
		    }
		}
		
		// subtract from terrain
		gpu_set_blendmode(bm_subtract);
		for (var j=0; j<array_length(MAP.collision_grid); j++) {
			for (var k=0; k<array_length(MAP.collision_grid[i]); k++) {
				if (MAP.collision_grid[j][k] != "outside" && MAP.collision_grid[j][k] != "island") {
					draw_sprite(fog_cell, 0, j*cell-_x, k*cell-_y);
				}
			}
		}
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
			
		array_push(MAP.background_fog_surfaces, surf);
	}
	
	// generate fog surfaces
	for (var i=0; i<array_length(MAP.fog_surfaces); i++) {
		if (surface_exists(MAP.fog_surfaces[i])) surface_free(MAP.fog_surfaces[i]);
	}
	MAP.fog_surfaces = [];
	var cell = MAP.collision_grid_cell_size;
	for (var i=0; i<surface_count; i++) {
		var surf = surface_create(MAP.background_surface_size, MAP.background_surface_size);
		array_push(MAP.fog_surfaces, surf);
	}
	
	// generate permafog surfaces
	for (var i=0; i<array_length(MAP.permafog_surfaces); i++) {
		if (surface_exists(MAP.permafog_surfaces[i])) surface_free(MAP.permafog_surfaces[i]);
	}
	MAP.permafog_surfaces = [];
	var cell = MAP.collision_grid_cell_size;
	for (var i=0; i<surface_count; i++) {
		var surf = surface_create(MAP.background_surface_size, MAP.background_surface_size);
		
		surface_set_target(surf);
		draw_clear_alpha(c_black, 0);
		
		var fog_width = sprite_get_width(bg_stars_256);
		var tile_n = ceil(MAP.background_surface_size/fog_width);
		// Draw tiled fog background
		for (var xx = 0; xx < tile_n; xx++) {
		    for (var yy = 0; yy < tile_n; yy++) {
		        var draw_x = xx * fog_width;
		        var draw_y = yy * fog_width;
		        draw_sprite(bg_stars_256, irandom(2), draw_x, draw_y);
		    }
		}
		
		surface_reset_target();
		
		array_push(MAP.permafog_surfaces, surf);
	}
	
	
}

function draw_background_fog() {
	for (var i=0; i<array_length(MAP.background_fog_surfaces); i++) {
		if (!surface_exists(MAP.background_fog_surfaces[i])) {
			generate_fog_surfaces();
			break;
		}
		var _x = (i % MAP.surfaces_per_row) * MAP.background_surface_size;
		var _y = (i div MAP.surfaces_per_row) * MAP.background_surface_size;
		draw_surface(MAP.background_fog_surfaces[i], _x, _y);
	}
}
function draw_fog_lineofsight() {
	
	// poke holes in vision sprite
	var surface_width = sprite_get_width(soft_round_vision);
	var surface_height = sprite_get_height(soft_round_vision);
	var vision_surface = surface_create(surface_width, surface_height);
	var temp_surface = surface_create(surface_width, surface_height);
	var scale = PLAYER.character_main.stats.vision/90;
	var cell = MAP.collision_grid_cell_size;
	
	surface_set_target(temp_surface);
		draw_clear_alpha(c_black, 0);
		for (var i=0; i<array_length(PLAYER.vision_blockers); i++) {
			var blocker = PLAYER.vision_blockers[i];
			// Calculate blocker position relative to player (surface space)
		    var blocker_surface_x = blocker.x * cell + cell/2 - PLAYER.position.x + surface_width/2;
		    var blocker_surface_y = blocker.y * cell + cell/2 - PLAYER.position.y + surface_height/2;
			var dir_to_blocker = point_direction(surface_width/2, surface_height/2, blocker_surface_x, blocker_surface_y);
			var dis_to_blocker = point_distance(surface_width/2, surface_height/2, blocker_surface_x, blocker_surface_y);
			// Cone parameters
		    var cone_length = surface_width; // How far the cone extends past the blocker
		    var cone_width = cell;   // Width of the cone at the blocker
		
		    // Calculate the four corners of the stretched square
		    var x1 = blocker_surface_x + lengthdir_x(cone_width/2, dir_to_blocker + 90);
		    var y1 = blocker_surface_y + lengthdir_y(cone_width/2, dir_to_blocker + 90);
		    var x2 = blocker_surface_x + lengthdir_x(cone_width/2, dir_to_blocker - 90);
		    var y2 = blocker_surface_y + lengthdir_y(cone_width/2, dir_to_blocker - 90);
			var cone_angle_width = normalize(200/dis_to_blocker-cell, 0, 200)*150;
		    var x3 = x2 + lengthdir_x(cone_length, point_direction(surface_width/2, surface_height/2, x2, y2)+cone_angle_width);
		    var y3 = y2 + lengthdir_y(cone_length, point_direction(surface_width/2, surface_height/2, x2, y2)+cone_angle_width);
		    var x4 = x1 + lengthdir_x(cone_length, point_direction(surface_width/2, surface_height/2, x1, y1)-cone_angle_width);
		    var y4 = y1 + lengthdir_y(cone_length, point_direction(surface_width/2, surface_height/2, x1, y1)-cone_angle_width);
		
			draw_sprite_pos(square_16, 0, x1, y1, x2, y2, x3, y3, x4, y4, 1);
		}
		gpu_set_blendmode(bm_subtract);
		for (var i=0; i<array_length(PLAYER.vision_blockers); i++) {
			var blocker = PLAYER.vision_blockers[i];
			var asset = MAP.assets_grid[blocker.x][blocker.y];
			if (asset != undefined) {
				asset.draw(asset.x - PLAYER.position.x + surface_width/2, asset.y - PLAYER.position.y + surface_height/2);
			}
		}
		gpu_set_blendmode(bm_normal);
	surface_reset_target();
	
	surface_set_target(vision_surface);
		draw_clear_alpha(c_black, 0);
		draw_sprite(soft_round_vision, 0, sprite_get_xoffset(soft_round_vision), sprite_get_yoffset(soft_round_vision));
		gpu_set_blendmode(bm_subtract);
		draw_surface(temp_surface, 0, 0);
		gpu_set_blendmode(bm_normal);
	surface_reset_target();
	
	
	for (var i=0; i<array_length(MAP.fog_surfaces); i++) {
		if (!surface_exists(MAP.fog_surfaces[i])) {
			generate_fog_surfaces();
			break;
		}
		var _x = (i % MAP.surfaces_per_row) * MAP.background_surface_size;
		var _y = (i div MAP.surfaces_per_row) * MAP.background_surface_size;
		
		
		surface_set_target(MAP.fog_surfaces[i]);
		
		var fog_width = sprite_get_width(bg_stars_256);
		var tile_n = ceil(MAP.background_surface_size/fog_width);
		// Draw tiled fog background
		for (var xx = 0; xx < tile_n; xx++) {
		    for (var yy = 0; yy < tile_n; yy++) {
		        var draw_x = xx * fog_width;
		        var draw_y = yy * fog_width;
		        draw_sprite_ext(bg_stars_256, MAP.fog_sprite_index, draw_x, draw_y, 1, 1, 0, c_white, MAP.fog_revealed_alpha);
		    }
		}
		
		// subtract vision and any assets that need to not have fog on top (dynamic assets)
		gpu_set_blendmode(bm_subtract);
		repeat(5) draw_surface_ext(vision_surface, PLAYER.position.x-_x-surface_width/2, PLAYER.position.y-_y-surface_height/2, 1, 1, 0, c_white, 1);
		for (var j=0;j<array_length(MAP.dynamic_assets);j++) {
			var asset = MAP.dynamic_assets[j];
			if (asset.visible) {
				draw_sprite_ext(asset.sprite_index, asset.image_index, asset.x-_x, asset.y-_y, asset.image_xscale, asset.image_yscale, 0, c_white, 1);
			}
		}
		surface_reset_target();
		
		surface_set_target(MAP.permafog_surfaces[i]);
		if (PLAYER.revealing_fog > 0) draw_sprite_ext(soft_round_vision, 0, PLAYER.position.x-_x, PLAYER.position.y-_y, .75, .75, 0, c_white, 1);
		surface_reset_target();
		
		gpu_set_blendmode(bm_normal);
		
		 
		draw_surface(MAP.fog_surfaces[i], _x, _y);
		if (!DEV) draw_surface(MAP.permafog_surfaces[i], _x, _y);
		
	}
	
	surface_free(vision_surface);
	surface_free(temp_surface);
}
function draw_fog() {

	for (var i=0; i<array_length(MAP.fog_surfaces); i++) {
		if (!surface_exists(MAP.fog_surfaces[i])) {
			generate_fog_surfaces();
			break;
		}
		var _x = (i % MAP.surfaces_per_row) * MAP.background_surface_size;
		var _y = (i div MAP.surfaces_per_row) * MAP.background_surface_size;
		
		
		surface_set_target(MAP.fog_surfaces[i]);
		
		var fog_width = sprite_get_width(bg_stars_256);
		var tile_n = ceil(MAP.background_surface_size/fog_width);
		// Draw tiled fog background
		for (var xx = 0; xx < tile_n; xx++) {
		    for (var yy = 0; yy < tile_n; yy++) {
		        var draw_x = xx * fog_width;
		        var draw_y = yy * fog_width;
		        draw_sprite_ext(bg_stars_256, MAP.fog_sprite_index, draw_x, draw_y, 1, 1, 0, c_white, MAP.fog_revealed_alpha);
		    }
		}
		
		// subtract vision and any assets that need to not have fog on top (dynamic assets)
		gpu_set_blendmode(bm_subtract);
		var scale = PLAYER.stats.vision/200;
		repeat(1) draw_sprite_ext(soft_round_vision, 0, PLAYER.position.x-_x, PLAYER.position.y-_y, scale, scale, 0, c_white, 1);
		for (var j=0;j<array_length(MAP.dynamic_assets);j++) {
			var asset = MAP.dynamic_assets[j];
			if (asset.visible) {
				draw_sprite_ext(asset.sprite_index, asset.image_index, asset.position.x-_x, asset.position.y-_y, asset.image_xscale, asset.image_yscale, 0, c_white, 1);
			}
		}
		surface_reset_target();
		
		surface_set_target(MAP.permafog_surfaces[i]);
		if (PLAYER.revealing_fog > 0) draw_sprite_ext(soft_round_vision, 0, PLAYER.position.x-_x, PLAYER.position.y-_y, scale*.9, scale*.9, 0, c_white, 1);
		surface_reset_target();
		
		gpu_set_blendmode(bm_normal);
		
		 
		if (!DEV) draw_surface(MAP.permafog_surfaces[i], _x, _y);
		draw_surface(MAP.fog_surfaces[i], _x, _y);
		
	}
}

function reveal_fog(center_x, center_y, radius, height_ratio) {
    
	var cell = MAP.collision_grid_cell_size;
	var grid_radius = ceil(radius / cell);
    var center_grid_x = floor(center_x / cell);
    var center_grid_y = floor(center_y / cell);
	
	// hide revealed cells
    for (var dx = -grid_radius-1; dx <= grid_radius+1; dx++) {
        for (var dy = -grid_radius-1; dy <= grid_radius+1; dy++) {
            var grid_x = center_grid_x + dx;
            var grid_y = center_grid_y + dy;
            
            if (is_valid_grid_cell(grid_x, grid_y)) {
                var world_x = grid_x * cell + cell / 2;
                var world_y = grid_y * cell + cell / 2;
                if (point_in_ellipse(world_x, world_y, center_x, center_y, radius+cell, height_ratio)) {
                    if (MAP.fog_grid[grid_x][grid_y] == "vision") MAP.fog_grid[grid_x][grid_y] = "revealed";
                }
            }
        }
    }
	
	// reveal cells
	var assets_to_reveal = [];
    for (var dx = -grid_radius; dx <= grid_radius; dx++) {
        for (var dy = -grid_radius; dy <= grid_radius; dy++) {
            var grid_x = center_grid_x + dx;
            var grid_y = center_grid_y + dy;
            
            if (is_valid_grid_cell(grid_x, grid_y)) {
                
                // Check if this grid cell is within the circle
                var world_x = grid_x * cell + cell / 2;
                var world_y = grid_y * cell + cell / 2;
                if (point_in_ellipse(world_x, world_y, center_x, center_y, radius, height_ratio)) {
                    if (MAP.collision_grid[grid_x][grid_y] == "free") {
						if (MAP.fog_grid[grid_x][grid_y] != "static vision") MAP.fog_grid[grid_x][grid_y] = "vision";
					} else if (MAP.fog_grid[grid_x][grid_y] == "fog" && MAP.assets_grid[grid_x][grid_y] != undefined) {
						if (MAP.fog_grid[grid_x][grid_y] != "static vision") MAP.fog_grid[grid_x][grid_y] = "vision";
						// and reveal any asset that is in the cell
						array_push(assets_to_reveal, [grid_x, grid_y]);
					} else if (MAP.collision_grid[grid_x][grid_y] == "blocked") {
						if (MAP.fog_grid[grid_x][grid_y] != "static vision") MAP.fog_grid[grid_x][grid_y] = "vision";
					}
                }
            }
        }
    }
	// Draw revealed assets to surfaces (outside the main loop for performance)
    if (array_length(assets_to_reveal) > 0) {
        draw_revealed_assets_to_surfaces(assets_to_reveal);
    }
}


function draw_revealed_assets_to_surfaces(assets_array) {
    var cell_size = MAP.collision_grid_cell_size;
    
	gpu_set_blendmode(bm_subtract);
    for (var i = 0; i < array_length(assets_array); i++) {
        var grid_pos = assets_array[i];
        var grid_x = grid_pos[0];
        var grid_y = grid_pos[1];
        
        var world_x = grid_x * cell_size;
        var world_y = grid_y * cell_size;
        
        var surf_index = find_bg_surf_index(world_x, world_y);
        if (surf_index != -1 && surface_exists(MAP.permafog_surfaces[surf_index])) {
            var surface_x = floor(world_x / MAP.background_surface_size);
            var surface_y = floor(world_y / MAP.background_surface_size);
            
            surface_set_target(MAP.permafog_surfaces[surf_index]);
            var asset = MAP.assets_grid[grid_x][grid_y];
            asset.draw_reveal(asset.x - surface_x * MAP.background_surface_size, 
                      asset.y - surface_y * MAP.background_surface_size);
            surface_reset_target();
        }
    }
	gpu_set_blendmode(bm_normal);
}


// helpers
function in_vision(_x, _y) {
	var gridx = to_grid(_x), gridy = to_grid(_y);
	return (MAP.fog_grid[gridx][gridy] == "vision" || MAP.fog_grid[gridx][gridy] == "static vision");
}
function in_vision_grid(gridx, gridy) {
	return (MAP.fog_grid[gridx][gridy] == "vision" || MAP.fog_grid[gridx][gridy] == "static vision");
}




// line of sight stuff
function reveal_fog_lineofsight(center_x, center_y, radius, height_ratio) {
	
    var cell_size = MAP.collision_grid_cell_size;
    var grid_radius = ceil(radius / cell_size);
    var center_grid_x = floor(center_x / cell_size);
    var center_grid_y = floor(center_y / cell_size);
    
    
    // Hide previously revealed cells
    for (var dx = -grid_radius - 1; dx <= grid_radius + 1; dx++) {
        for (var dy = -grid_radius - 1; dy <= grid_radius + 1; dy++) {
            var grid_x = center_grid_x + dx;
            var grid_y = center_grid_y + dy;
            
            if (is_valid_grid_cell(grid_x, grid_y)) {
                var world_x = grid_x * cell_size + cell_size / 2;
                var world_y = grid_y * cell_size + cell_size / 2;
                if (point_in_ellipse(world_x, world_y, center_x, center_y, radius + cell_size, height_ratio)) {
                    if (MAP.fog_grid[grid_x][grid_y] == "vision") MAP.fog_grid[grid_x][grid_y] = "revealed";
                }
            }
        }
    }
    
    // update grid for line-of-sight
    update_vision(center_x, center_y, radius, 360, height_ratio);
	
	
	// unfog cells and fill blockers
    var assets_to_reveal = []; // Store assets to reveal later
	PLAYER.vision_blockers = [];
    for (var dx = -grid_radius; dx <= grid_radius; dx++) {
        for (var dy = -grid_radius; dy <= grid_radius; dy++) {
            var grid_x = center_grid_x + dx;
            var grid_y = center_grid_y + dy;
            
            if (!is_valid_grid_cell(grid_x, grid_y)) continue; 
                
            // Check if this grid cell is within the circle
            var world_x = grid_x * cell_size + cell_size / 2;
            var world_y = grid_y * cell_size + cell_size / 2;
            if (point_in_ellipse(world_x, world_y, center_x, center_y, radius, height_ratio)) {
				if (MAP.collision_grid[grid_x][grid_y] != "free") {
					array_push(PLAYER.vision_blockers, {x:grid_x, y:grid_y});
					if (MAP.fog_grid[grid_x][grid_y] == "fog" && MAP.assets_grid[grid_x][grid_y] != undefined) {
						MAP.fog_grid[grid_x][grid_y] = "revealed";
						// and reveal any asset that is in the cell
						array_push(assets_to_reveal, [grid_x, grid_y]);
					}
				}
            }
        }
    }
    
    // Draw revealed assets to surfaces (outside the main loop for performance)
    if (array_length(assets_to_reveal) > 0) {
        draw_revealed_assets_to_surfaces(assets_to_reveal);
    }
}

function update_vision(player_x, player_y, vision_radius, fov_angle = 360, height_ratio) {
    var cell_size = MAP.collision_grid_cell_size;
    
    // Cast rays to find blocking cells
    var ray_count = 36; // More rays = smoother cones
    for (var i = 0; i < ray_count; i++) {
        var angle = (i / ray_count) * fov_angle;
        cast_vision_ray_ellipse(player_x, player_y, angle, vision_radius, height_ratio);
    }
}

function cast_vision_ray_ellipse(start_x, start_y, angle, radius, height_ratio) {
    var cell_size = MAP.collision_grid_cell_size;
    var step_size = cell_size / 4;
    var dist = 0;
    
    // Calculate maximum distance for this angle in the ellipse
    var max_dist = get_ellipse_radius_at_angle(radius, radius*height_ratio, angle);
    
    while (dist < max_dist) {
        dist += step_size;
        
        // Calculate point along ray
        var check_x = start_x + lengthdir_x(dist, angle);
        var check_y = start_y + lengthdir_y(dist, angle);
        
        // Check if we're still inside the ellipse
        if (!point_in_ellipse(check_x, check_y, start_x, start_y, radius, height_ratio)) {
            return undefined; // Outside ellipse
        }
        
        var grid_x = floor(check_x / cell_size);
        var grid_y = floor(check_y / cell_size);
        
        if (!is_valid_grid_cell(grid_x, grid_y)) {
            return undefined; // Out of bounds
        }
        
        // Found a blocker - return its position and angle
        if (MAP.collision_grid[grid_x][grid_y] != "free") {
            return {
                x: grid_x,
                y: grid_y,
                angle: angle,
                distance: dist
            };
        } else {
            // Set fog grid to vision (assets are revealed in the asset reveal function)
			if (MAP.assets_grid[grid_x][grid_y] == undefined) MAP.fog_grid[grid_x][grid_y] = "vision";
        }
    }
    
    return undefined; // No blocker found
}

function get_ellipse_radius_at_angle(radius_x, radius_y, angle) {
    // Convert angle to radians for math functions
    var angle_rad = degtorad(angle);
    
    // Ellipse radius formula: r = (a*b) / sqrt((b*cosθ)² + (a*sinθ)²)
    var cos_angle = cos(angle_rad);
    var sin_angle = sin(angle_rad);
    
    var denominator = sqrt(power(radius_y * cos_angle, 2) + power(radius_x * sin_angle, 2));
    
    if (denominator == 0) return 0;
    return (radius_x * radius_y) / denominator;
}
