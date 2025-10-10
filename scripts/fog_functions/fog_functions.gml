// script goes brrrrrr


function generate_fog_surfaces() {
	MAP.surfaces_per_row = MAP.size*TILE/MAP.background_surface_size;
	var surface_count = power(MAP.surfaces_per_row, 2);
	// generate new background surfaces
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
	MAP.fog_surfaces = [];
	var cell = MAP.collision_grid_cell_size;
	for (var i=0; i<surface_count; i++) {
		var surf = surface_create(MAP.background_surface_size, MAP.background_surface_size);
		array_push(MAP.fog_surfaces, surf);
	}
	
	// generate fog surfaces
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
		
		var scale = PLAYER.character_main.stats.vision/84;
		// subtract vision
		gpu_set_blendmode(bm_subtract);
		repeat(5) draw_sprite_ext(soft_round_256, 0, PLAYER.position.x-_x, PLAYER.position.y-_y, 1*scale, .67*scale, 0, c_white, 1);
		surface_reset_target();
		
		surface_set_target(MAP.permafog_surfaces[i]);
		if (PLAYER.revealing_fog > 0) draw_sprite_ext(soft_round_256, 0, PLAYER.position.x-_x, PLAYER.position.y-_y, 1*scale+.1, .67*scale+.1, 0, c_white, 1);
		surface_reset_target();
		
		gpu_set_blendmode(bm_normal);
		
		if (!DEV) {
			draw_surface(MAP.fog_surfaces[i], _x, _y);
			draw_surface(MAP.permafog_surfaces[i], _x, _y);
		}
	}
}

function reveal_fog(center_x, center_y, radius, height_ratio) {
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
                if (point_in_ellipse(world_x, world_y, center_x, center_y, radius, height_ratio)) {
                    MAP.fog_grid[grid_x][grid_y].type = "revealed";
                }
            }
        }
    }
}
