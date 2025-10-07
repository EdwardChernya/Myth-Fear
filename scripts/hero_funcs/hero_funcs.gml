// script goes brrrrrr
function stat_struct() constructor {
	
	// base stuff
	hp = 5;
	armor = .15;
	mresist = .05;
	ccresist = .05;
	dodge = .01;
	
	speed = 1;
	
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
		}
	}
	
}
function hero() constructor {
	
	// init
	stats = new stat_struct();
	state = "idle";
	moving = false;
	
	cctimer = 0;
	
	static update = function() {
		stats.update();
		// state stuff
		if (moving and state == "idle") state = "move";
		if (!moving and state == "move") state = "idle";
		
	}
	
	static draw = function() {
		
	}
}


function basic_hero() : hero() constructor {
	
	stats.speed = 5;
	
	static draw = function() {
		draw_sprite(_727_13_new, 0, PLAYER.position.x, PLAYER.position.y);
	}
	
}