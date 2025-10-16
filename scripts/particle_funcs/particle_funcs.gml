// script goes brrrrrr

function particle_system() constructor {
	
	surface = undefined;
	particles = [];
	
	static update = function() {
		for (var i=0; i<array_length(particles); i++) {
			particles[i].update();
		}
	}
	static draw = function() {
		if (surface_exists(surface)) {
			if (surface_get_width(surface) != round(CAMERA.world_width) || surface_get_height(surface) != round(CAMERA.world_height)) {
				surface_resize(surface, round(CAMERA.world_width), round(CAMERA.world_height));
			}
		} else {
			surface = surface_create(round(CAMERA.world_width), round(CAMERA.world_height));
		}
		gpu_set_blendmode(bm_add);
		surface_set_target(surface);
		draw_clear_alpha(c_black, 0);
		for (var i=0; i<array_length(particles); i++) {
			particles[i].draw();
		}
		surface_reset_target();
		draw_surface(surface, floor(CAMERA.x-CAMERA.world_width/2), floor(CAMERA.y-CAMERA.world_height/2));
		gpu_set_blendmode(bm_normal);
	}
	
}

function base_particle(x, y) constructor {
	
	position = new Vector2(x, y);
	
	life = 60;
	
	destroyed = false;
	destroy_function = undefined;
	draw_function = undefined;
	update_function = undefined;
	
	array_push(PARTICLE_SYSTEM.particles, self);
	
	static update = function() {
		if (update_function != undefined) update_function(self);
		
		life -= 1;
		if (life <= 0) clear();
	}
	static draw = function() {
		if (draw_function != undefined) draw_function(self);
	}
	static clear = function() {
		var _f = function(_element, _index) {
			return (_element == self);
		}
		var _index = array_find_index(PARTICLE_SYSTEM.particles, _f);
		if (_index != -1) {
			array_delete(PARTICLE_SYSTEM.particles, _index, 1);
		}
		if (destroy_function != undefined and !destroyed) {
			destroyed = true;
			destroy_function(self);
		}
	}
}

function reward_trail_particle(x, y, color1, color2=color1) : base_particle(x, y) constructor {
	
	target = PLAYER.position;
	life = 60*3;
	
	positions = [];
	hue1 = color_get_hue(color1);
	sat1 = color_get_saturation(color1);
	hue2 = color_get_hue(color2);
	sat2 = color_get_saturation(color2);
	
	static get_hue = function(_i) {
		return lerp(hue1, hue2, _i/trail_length);
	}
	static get_sat = function(_i) {
		return lerp(sat1, sat2, _i/trail_length);
	}
	static get_val = function(_i) {
		return clamp(255-255*(_i/trail_length), 0, 255);
	}
	width = 5;
	
	trail_update_per_frames = 60/20;
	trail_update_timer = 0;
	
	trail_length = 5;
	
	speed = random_range(2, 9);
	velocity = new Vector2();
	velocity.from_angle(irandom(360));
	velocity.Normalize();
	velocity.Multiply(speed);
	turn_speed = .2;
	
	update_function = function(_self) {
		with (_self) {
			
			// movement logic
			var to_target = new Vector2(target.x, target.y-32);
			to_target.Subtract(position);
			var distance = to_target.Length();
			if (distance < 3) clear();
			to_target.Normalize();
			to_target.Multiply(turn_speed);
			velocity.Add(to_target);
			velocity.Multiply(.95);
				
			
			position.Add(velocity);
			
			// update positions
			trail_update_timer -= 1;
			if (trail_update_timer <= 0) {
				array_insert(positions, 0, new Vector2(position.x, position.y));
				trail_update_timer = trail_update_per_frames;
			}
		}
	}
	
	draw_function = function(_self) {
		with (_self) {
			var xoff = CAMERA.x-CAMERA.world_width/2, yoff = CAMERA.y-CAMERA.world_height/2;
			for (var i=0; i<array_length(positions); i++) {
				if (i==trail_length) break;
				if (i==0) {
					draw_line_width_color(position.x-xoff, position.y-yoff, positions[0].x-xoff, positions[0].y-yoff, width, 
					make_color_hsv(hue1, sat1, 1), make_color_hsv(get_hue(i+1), get_sat(i+1), get_val(i+1)));
				} else {
					draw_line_width_color(positions[i-1].x-xoff, positions[i-1].y-yoff, positions[i].x-xoff, positions[i].y-yoff, width, 
					make_color_hsv(get_hue(i), get_sat(i), get_val(i)), make_color_hsv(get_hue(i+1), get_sat(i+1), get_val(i+1)));
				}
			}
		}
	}
	
}