// script goes brrrrrr
function stat_struct() constructor {
	
	// base stuff
	vision = 200;
	speed = 5;
	
	hp = 5;
	armor = .15;
	mresist = .05;
	ccresist = .05;
	dodge = .01;
	
	
	adamage = 2;
	arange = 50;
	acooldown = 1;
	atimer = 0;
	acrit = 0;
	acritdmg = 2;
	
	resource = undefined;
	cdr = 0;
	
	// other stuff
	morale = 1;
	
	
	static update = function() {
		if (atimer > 0) {
			atimer -= 1; 
		} else {
			atimer = acooldown;
		}
	}
	
}

function animations_struct() constructor {
	idle = undefined;
	run = undefined;
	aattack = undefined;
}

function hero() constructor {
	
	// init
	x = 0;
	y = 0;
	visible = true;
	stats = new stat_struct();
	state = "idle";
	moving = false;
	sprite_index = _727_13_new;
	image_index = 0;
	image_speed = 1/60;
	image_xscale = 1;
	image_yscale = 1;
	image_alpha = 1;
	animations = new animations_struct();
	
	cctimer = 0;
	
	static update = function() {
		x = PLAYER.position.x;
		y = PLAYER.position.y;
		
		stats.update();
		// state stuff
		if (moving and state == "idle") state = "move";
		if (!moving and state == "move") state = "idle";
		
		switch (state) {
			case "idle":
				sprite_index = animations.idle;
				image_index = 0;
				break;
		}
		image_index += image_speed;
	}
	
	static draw = function() {
		
	}
}


function basic_hero() : hero() constructor {
	
	stats.speed = 5;
	animations.idle = _727_13_new;
	
	static draw = function() {
		draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, c_white, image_alpha);
	}
	
}