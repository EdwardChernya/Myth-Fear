// script goes brrrrrr
function stat_struct() constructor {
	
	// base stuff
	vision = 200;
	speed = 1.3;
	
	hp = 5;
	armor = 1;
	mresist = .05;
	ccresist = .05;
	dodge = .01;
	
	
	adamage = 2;
	adamage_type = "physical";
	adamage_bonuses = [];
	arange = 50;
	aspeed = 1; 
		acap = 3; 
	bspeed = 1;
		bcap = 2; // has to be smaller than attack speed or auto attackers will go crazy?
	acrit = 0;
	acritdmg = 2;
	
	resource = undefined;
	cdr = 0;
	
	// other stuff
	morale = 1;
	
	
	static update = function() {
		
	}
	
}

// state and animation constructors
function animations_struct() constructor {
	idle = undefined;
	move = undefined;
	interact = undefined;
	aattack = undefined;
	cast = undefined;
	
	death = undefined;
	
	stun = undefined;
	flail = undefined;
}
function state_struct(_parent) constructor {
	
	name = "default";
	parent = _parent;
	
	state_has_ended = false;
	looping = false;
	can_force = false;
	
	enter_function = undefined;
	exit_function = undefined;
	update_function = undefined;
	update_begin_function = undefined;
	update_end_function = undefined;
	draw_function = undefined;
	
	code_index = 0;
	code_ran = false;
	image_speed = 1/60;
	
	static enter_state = function() {
		parent.image_index = 0;
		state_has_ended = false;
		code_ran = false;
		if (enter_function != undefined) enter_function(self);
	}
	static exit_state = function() {
		if (exit_function != undefined) exit_function(self);
	}
	
	static update = function() {
		if (update_function != undefined) update_function(self);
	}
	
	static draw_simple = function() {
		with (parent) draw_sprite_ext(sprite_index, image_index, floor(position.x), floor(position.y), image_xscale, image_yscale, 0, c_white, image_alpha);
	}
	static draw = function() {
		parent.image_index += parent.image_speed;
		if (draw_function != undefined) {
			draw_function(self);
		} else {
			draw_simple();
		}
	}
	static code_ended = function() { // animation cancels on mobile??? ;-;
		return (parent.image_index >= code_index);
	}
	static animation_ended = function() {
		if (looping) {
			return state_has_ended;
		}
		return (parent.image_index >= sprite_get_number(parent.sprite_index)-parent.image_speed);
	}
}

#region default states
function player_idle_state(_parent) : state_struct(_parent) constructor {
	
	name = "idle";
	parent = _parent;
	
	looping = true;
	can_force = true;
	image_speed = 1/60;
	
	enter_function = function(_self) {
		with (_self) {
			parent.revealing_fog = 60;
			parent.sprite_index = parent.animations.idle;
			parent.image_speed = image_speed;
			
		}
	}
	update_function = function(_self) {
		with (_self) {
			parent.grid_position.Set(to_grid(parent.position.x), to_grid(parent.position.y));
			parent.prev_grid_position.Set(parent.grid_position);
			if (MAP.dynamic_grid[parent.grid_position.x][parent.grid_position.y] == undefined) MAP.dynamic_grid[parent.grid_position.x][parent.grid_position.y] = parent;
			if (parent.near_interact != undefined) {
				parent.change_state(parent.interact);
			}
		}
	}
}
function player_move_state(_parent) : state_struct(_parent) constructor {
	
	name = "move";
	parent = _parent;
	
	looping = true;
	can_force = true;
	image_speed = 5/60;
	enter_function = function(_self) {
		with (_self) {
			parent.sprite_index = parent.animations.move;
			parent.image_speed = image_speed;
		}
	}
	update_function = function(_self) {
		with (_self) {
			if (parent.position.Distance(parent.prev_position) < .2) {
				parent.sprite_index = parent.animations.idle;
			} else {
				parent.sprite_index = parent.animations.move;
			}
			parent.prev_position.Set(parent.position);
			parent.revealing_fog = 60;
		}
	}
}
function player_interact_state(_parent) : state_struct(_parent) constructor {
	
	name = "interact";
	parent = _parent;
	
	looping = true;
	can_force = true;
	interact_timer = 999;
	image_speed = 7/60;
	
	enter_function = function(_self) {
		with (_self) {
			parent.revealing_fog = 60;
			interact_timer = parent.near_interact.timer;
			parent.sprite_index = parent.animations.interact;
			xscale_to_target(parent, parent.near_interact.position);
			parent.image_speed = image_speed;
		}
	}
	update_function = function(_self) {
		with (_self) {
			interact_timer -= 1;
			if (interact_timer <= 0) {
				state_has_ended = true;
				if (parent.near_interact != undefined) {
					parent.near_interact.activate = true;
					parent.near_interact = undefined;
				}
			}
		}
	}
}
#endregion

function hero() constructor {
	
	// init
	position = new Vector2();
	prev_position = new Vector2();
	
	grid_position = new Vector2();
	prev_grid_position = new Vector2();
	
	visible = true;
	stats = new stat_struct();
	
	#region states
	
	idle = new player_idle_state(self);
	move = new player_move_state(self);
	prev_move_vector = undefined;
	move_vector_skip = 1;
	interact = new player_interact_state(self);
	
	state = idle;
	state_buffer = undefined;
	
	#endregion
	
	sprite_index = _727_13_new;
	image_index = 0;
	image_speed = 1/60;
	image_xscale = 1;
	image_yscale = 1;
	image_alpha = 1;
	animations = new animations_struct();
	
	cctimer = 0;
	
	// other
	revealing_fog = 60;
	flow_field_delay = 60/3;
	flow_field_timer = flow_field_delay;  
	near_interact = undefined;
	
	
	static update_begin = function() {
		// fog
		if (revealing_fog > 0) revealing_fog -= 1;
		reveal_fog(position.x, position.y, stats.vision, .67);
		
		flow_field_timer -= 1;
		if (flow_field_timer <= 0) update_flow_field_fast();
		
	}
	static update = function() {
		
		stats.update();
		
		// state stuff
		state.update();
		
		
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
		near_interact = undefined;
	}
	
	static draw = function() {
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
}


function basic_hero() : hero() constructor {
	
	animations.idle = _727_13_new;
	animations.move = _727_13_new;
	animations.interact = _727_13_new;
	
	// enter state manually after setting up animations
	state.enter_state();
	
}