// script goes brrrrrr
function stat_struct() constructor {
	
	// base stuff
	vision = 200;
	speed = 4;
	
	hp = 5;
	armor = 1;
	mresist = .05;
	ccresist = .05;
	dodge = .01;
	
	
	adamage = 2;
	adamage_type = "physical";
	adamage_bonuses = [];
	arange = 50;
	acooldown = 1; // every 1*60 frames or 60/(1*60) per second
		atimer = 0;
		acap = .2; // 5 attacks per second, might be too fast
	acrit = 0;
	acritdmg = 2;
	
	resource = undefined;
	cdr = 0;
	
	// other stuff
	morale = 1;
	
	
	static update = function() {
		if (atimer > 0) {
			atimer -= 1/60; 
		} else {
			atimer = acooldown;
		}
	}
	
}

#region default states
function animations_struct() constructor {
	idle = undefined;
	run = undefined;
	interact = undefined;
	aattack = undefined;
	ablock = undefined;
	cast = undefined;
	stun = undefined;
	flail = undefined;
}
function state_struct() constructor {
	
	name = "default";
	
	state_has_ended = false;
	looping = false;
	
	enter_function = undefined;
	exit_function = undefined;
	update_function = undefined;
	update_begin_function = undefined;
	update_end_function = undefined;
	draw_function = undefined;
	
	static enter_state = function() {
		PLAYER.image_index = 0;
		state_has_ended = false;
		if (enter_function != undefined) enter_function(self);
	}
	static exit_state = function() {
		if (exit_function != undefined) exit_function(self);
	}
	
	static update = function() {
		if (update_function != undefined) update_function(self);
	}
	
	static draw_simple = function() {
		with (PLAYER) draw_sprite_ext(sprite_index, image_index, floor(position.x), floor(position.y), image_xscale, image_yscale, 0, c_white, image_alpha);
	}
	static draw = function() {
		PLAYER.image_index += PLAYER.image_speed;
		if (draw_function != undefined) {
			draw_function(self);
		} else {
			draw_simple();
		}
	}
	static code_ended = function() { // animation cancels on mobile??? ;-;
		
	}
	static animation_ended = function() {
		if (looping) {
			return state_has_ended;
		}
		return (PLAYER.image_index >= sprite_get_number(PLAYER.sprite_index));
	}
}
function idle_state() : state_struct() constructor {
	
	name = "idle";
	
	looping = true;
	can_force = true;
	
	enter_function = function(_self) {
		with (_self) {
			PLAYER.revealing_fog = 60;
			PLAYER.sprite_index = PLAYER.animations.idle;
			PLAYER.image_speed = 1/60;
			
		}
	}
	update_function = function(_self) {
		with (_self) {
			if (PLAYER.near_interact != undefined) {
				PLAYER.change_state(PLAYER.interact);
			}
		}
	}
}
function move_state() : state_struct() constructor {
	
	name = "move";
	looping = true;
	can_force = true;
	image_speed = 1/60;
	enter_function = function(_self) {
		with (_self) {
			PLAYER.sprite_index = PLAYER.animations.move;
			PLAYER.image_speed = image_speed;
		}
	}
	update_function = function(_self) {
		with (_self) {
			PLAYER.revealing_fog = 60;
		}
	}
}
function interact_state() : state_struct() constructor {
	
	name = "interact";
	looping = true;
	can_force = true;
	interact_timer = 999;
	
	enter_function = function(_self) {
		with (_self) {
			PLAYER.revealing_fog = 60;
			interact_timer = PLAYER.near_interact.timer;
			PLAYER.sprite_index = PLAYER.animations.interact;
			xscale_to_target(PLAYER, PLAYER.near_interact.position);
			PLAYER.image_speed = 1/60;
		}
	}
	update_function = function(_self) {
		with (_self) {
			interact_timer -= 1;
			if (interact_timer <= 0) {
				state_has_ended = true;
				if (PLAYER.near_interact != undefined) {
					PLAYER.near_interact.activate = true;
					PLAYER.near_interact = undefined;
				}
			}
		}
	}
}
#endregion

function hero() constructor {
	
	// init
	position = new Vector2();
	visible = true;
	stats = new stat_struct();
	
	#region states
	
	idle = new idle_state();
	move = new move_state();
	interact = new interact_state();
	
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
	near_interact = undefined;
	
	static update_begin = function() {
	}
	static update = function() {
		position.Set(PLAYER.position);
		
		stats.update();
		
		// state stuff
		state.update();
		
		// fog
		if (revealing_fog > 0) revealing_fog -= 1;
		reveal_fog(position.x, position.y, stats.vision, .67);
		
		if (state.animation_ended()) {
			if (state_buffer != undefined) {
				change_state(state_buffer);
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
	
}