// script goes brrrrrr
function cloth(_parent, _color1, _color2) constructor {
	parent = _parent;
	
	length = 10;
	points = [];
	velocities = [];
	
	grav = .02; // force of gravity pulling towards the ground
	distance = 3; // maximum distance between points
	stiffness = .05;
	damping = .95;
	
	c1 = _color1;
	c2 = _color2;
	width = 16;
	
	tex = sprite_get_texture(_cape, 0);
	
	// setup arrays
	for (var i=0;i<length;i++) {
		array_push(points, new Vector2(parent.position));
		array_push(velocities, new Vector2());
	}
	
	static update = function() {
		points[0].Set(parent.position.x, parent.position.y-43);
		velocities[0].Set(0);
		
		// Apply physics to other points
		for (var i = 1; i < array_length(points); i++) {
			// Apply gravity
			velocities[i].y += grav;
			
			// Apply damping
			velocities[i].Multiply(damping);
			
			// Update position
			points[i].Add(velocities[i]);
			
			// Constraint: maintain distance from previous point
			var prev_point = points[i-1];
			var current_point = points[i];
			
			var dx = current_point.x - prev_point.x;
			var dy = current_point.y - prev_point.y;
			var current_dist = sqrt(dx*dx + dy*dy);
			
			if (current_dist > distance) {
				var correction_x = dx * (current_dist - distance) / current_dist * stiffness;
				var correction_y = dy * (current_dist - distance) / current_dist * stiffness;
				
				// Move current point back towards previous point
				points[i].x -= correction_x;
				points[i].y -= correction_y;
				
				// Also adjust velocity
				velocities[i].x -= correction_x * 0.5;
				velocities[i].y -= correction_y * 0.5;
			}
			
			// Optional: Add some air resistance/wind
			velocities[i].x *= 0.99;
		}
		
		// Secondary constraints for better cloth behavior
		for (var iter = 0; iter < 2; iter++) {
			for (var i = 1; i < array_length(points); i++) {
				var prev_point = points[i-1];
				var current_point = points[i];
				
				var dx = current_point.x - prev_point.x;
				var dy = current_point.y - prev_point.y;
				var current_dist = sqrt(dx*dx + dy*dy);
				
				if (current_dist > distance) {
					var ratio = distance / current_dist;
					var target_x = prev_point.x + dx * ratio;
					var target_y = prev_point.y + dy * ratio;
					
					points[i].x = lerp(points[i].x, target_x, 0.5);
					points[i].y = lerp(points[i].y, target_y, 0.5);
				}
			}
		}
	}
	
	static draw = function() {
		var color = make_color_rgb(40, 40, 40);
		draw_set_color(c_ltgray);
		draw_primitive_begin_texture(pr_trianglelist, tex);
		for (var i = 0; i < array_length(points) - 1; i++) {
        
	        // Direction for this segment
	        var dir_x = points[i+1].x - points[i].x;
	        var dir_y = points[i+1].y - points[i].y;
	        var len = sqrt(dir_x * dir_x + dir_y * dir_y);
	        if (len > 0) {
	            dir_x /= len;
	            dir_y /= len;
	        }
        
	        var perp1_x = -dir_y * width * 0.5;
	        var perp1_y = dir_x * width * 0.5;
	        var perp2_x = -dir_y * width * 0.5;
	        var perp2_y = dir_x * width * 0.5;
        
	        // For the first segment, draw both triangles normally
			if (i == 0) {
			    // Triangle 1
			    draw_vertex_texture(points[i].x + perp1_x, points[i].y + perp1_y, 1, 0);
			    draw_vertex_texture(points[i].x - perp1_x, points[i].y - perp1_y, 0, 0);
			    draw_vertex_texture(points[i+1].x + perp2_x, points[i+1].y + perp2_y, 1, (i+1)/length);
        
			    // Triangle 2
			    draw_vertex_texture(points[i].x - perp1_x, points[i].y - perp1_y, 0, 0);
			    draw_vertex_texture(points[i+1].x - perp2_x, points[i+1].y - perp2_y, 0, (i+2)/length);
			    draw_vertex_texture(points[i+1].x + perp2_x, points[i+1].y + perp2_y, 1, (i+2)/length);
			} else {
			    // For subsequent segments, reuse the previous segment's end vertices
			    // as the start vertices for this segment
				
				// Direction for this segment
			    var prev_dir_x = points[i].x - points[i-1].x;
			    var prev_dir_y = points[i].y - points[i-1].y;
			    var prev_len = sqrt(prev_dir_x * prev_dir_x + prev_dir_y * prev_dir_y);
			    if (prev_len > 0) {
			        prev_dir_x /= prev_len;
			        prev_dir_y /= prev_len;
			    }
        
			    var prev_perp1_x = -prev_dir_y * width * 0.5;
			    var prev_perp1_y = prev_dir_x * width * 0.5;
			    var prev_perp2_x = -prev_dir_y * width * 0.5;
			    var prev_perp2_y = prev_dir_x * width * 0.5;
				
			    // Triangle 1 - reuse previous right vertex and create new right vertex
			    draw_vertex_texture(points[i].x + prev_perp1_x, points[i].y + prev_perp1_y, 1, (i+1)/length); // Reused from previous
			    draw_vertex_texture(points[i].x - prev_perp1_x, points[i].y - prev_perp1_y, 0, (i+1)/length); // Reused from previous  
			    draw_vertex_texture(points[i+1].x + perp2_x, points[i+1].y + perp2_y, 1, (i+2)/length); // New
        
			    // Triangle 2 - reuse previous left vertex and create new left vertex
			    draw_vertex_texture(points[i].x - prev_perp1_x, points[i].y - prev_perp1_y, 0, (i+1)/length); // Reused from previous
			    draw_vertex_texture(points[i+1].x - perp2_x, points[i+1].y - perp2_y, 0, (i+2)/length); // New
			    draw_vertex_texture(points[i+1].x + perp2_x, points[i+1].y + perp2_y, 1, (i+2)/length); // New
			}
	    }
    
	    draw_primitive_end();
	}
	
	static reset_positions = function() {
		for (var i=0;i<array_length(points);i++) {
			points[i].Set(parent.position);
			velocities[i].Set(0);
		}
	}
	
	static add_force = function(_force) {
		for (var i = 1; i < array_length(velocities); i++) {
			velocities[i].x += _force.x;
			velocities[i].y += _force.y;
		}
	}
	
}