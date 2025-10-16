/// @description Insert description here
// You can write your code in this editor

event_inherited();


if (!is_area_within_bounds(grid_x-2, grid_y-1, grid_x+1, grid_y)) {
	instance_destroy();
	exit;
}

var _x = grid_x*cell;
var _y = grid_y*cell;

destroy_square_area_grid(grid_x-2, grid_y-1, grid_x+1, grid_y-1);
destroy_square_area_grid(grid_x-1, grid_y, grid_x, grid_y);

var asset = new static_asset(_x, _y, grid_x, grid_y, "relic");
asset.sprite_index = sprite_index;
asset.xscale = image_xscale;
asset.active = true;
asset.activate = false;
asset.effect_alpha = 1;
asset.timer = 60;
asset.reward_amount = 3;
asset.reward_timer = asset.timer;
asset.update_begin_function = function(_self) {
	with (_self) {
		if (!activate && point_distance(position.x, position.y, PLAYER.position.x, PLAYER.position.y) < 80) PLAYER.near_interact = self;
	}
}
asset.update_function = function(_self) {
	with (_self) {
		if (active && activate) {
			effect_alpha -= 1/timer;
			reward_timer -= 1;
			if (reward_timer mod floor(timer/reward_amount) == 0) new reward_trail_particle(position.x, position.y-32, c_aqua, c_blue);
			if (reward_timer <= 0) active = false;
		}
	}
}
asset.draw_function = function(_self, _x, _y, _scale) {
	with (_self) {
		var vision = in_vision_grid(grid_x, grid_y);
		//if (active && vision) { // light
		//	gpu_set_blendmode(bm_add);
		//	var c = make_color_hsv(180, 255, 255);
		//	var c2 = make_color_hsv(160, 255, 255);
		//	draw_sprite_ext(soft_round_vision, 0, position.x, position.y, .5, .5, 0, c_blue, .025*get_sine());
		//	draw_sprite_ext(soft_round_vision, 0, position.x, position.y, .3, .3, 0, c2, .05*get_sine());
		//	gpu_set_blendmode(bm_normal);
		//}
		draw_simple(_x, _y, _scale);
		if (active) {
			var a = vision ? .3+get_sine() : 1;
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(relic_add, 0, _x-31, _y-80, 1, 1, 0, c_white, a*effect_alpha);
			gpu_set_blendmode(bm_normal);
		}
	}
}
asset.draw_reveal_function = function(_self, _x, _y, _scale) {
	with (_self) {
		draw_simple(_x, _y, _scale);
		draw_sprite(relic_add, 0, _x-31, _y-80);
	}
}

mark_square_area_grid(MAP.collision_grid, grid_x-2, grid_y-1, grid_x+1, grid_y-1, "blocked");
mark_square_area_grid(MAP.collision_grid, grid_x-1, grid_y, grid_x, grid_y, "blocked");
mark_square_area_grid(MAP.assets_grid, grid_x-2, grid_y-1, grid_x+1, grid_y-1, asset);
mark_square_area_grid(MAP.assets_grid, grid_x-1, grid_y, grid_x, grid_y, asset);

var destroy_func = function(_self) {
	with (_self) {
		mark_square_area_grid(MAP.collision_grid, grid_x-2, grid_y-1, grid_x+1, grid_y-1, "free");
		mark_square_area_grid(MAP.collision_grid, grid_x-1, grid_y, grid_x, grid_y, "free");
		mark_square_area_grid(MAP.assets_grid, grid_x-2, grid_y-1, grid_x+1, grid_y-1, undefined);
		mark_square_area_grid(MAP.assets_grid, grid_x-1, grid_y, grid_x, grid_y, undefined);
		clear(MAP.interact_array);
	}
}
asset.destroy_function = destroy_func;

insert_static_asset(asset);
array_push(MAP.interact_array, asset);

instance_destroy();