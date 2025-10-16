/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;


// init particles
PARTICLE_SYSTEM.particles = [];


// get background layer id
var layer_id = layer_get_id("Background");
back_id = layer_background_get_id(layer_id);

// generate map
generate_map(world);

// sort static assets for quick depth
var number_of_assets = 0;
for (var xx =0; xx < array_length(static_assets); xx++) {
	for (var yy =0; yy < array_length(static_assets[xx]); yy++) {
		if (static_assets[xx][yy] != undefined) number_of_assets++;
	}
}
DEBUG.add($"{number_of_assets} total static assets", c_lime);




// setup camera and player
destroy_square_area_grid(to_grid(MAP.last_node.x), to_grid(MAP.last_node.y), to_grid(MAP.last_node.x), to_grid(MAP.last_node.y));
PLAYER.position.Set(MAP.last_node);
PLAYER.revealing_fog = 60;

if (!DEV) {
	CAMERA.target = PLAYER;
	CAMERA.x = PLAYER.position.x;
	CAMERA.y = PLAYER.position.y;
	var wide_res = max(CAMERA.width, CAMERA.height);
	CAMERA.zoom = max(2, ceil(wide_res/room_width));
	CAMERA.smooth_zoom = CAMERA.default_zoom;
}

// dynamic assets
dynamic_assets = [];
array_push(dynamic_assets, PLAYER);


#region test lights

var test_light = new static_asset(PLAYER.position.x, PLAYER.position.y, 0, 0, "light");
test_light.update_function = function(_self) {
	with (_self) {
		position.x = PLAYER.position.x;
		position.y = PLAYER.position.y-200;
	}
}
test_light.draw_function = function(_self) {
	with (_self) {
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(soft_round_vision, 0, position.x, position.y+205, .5, .5, 0, c_blue, .1);	
		gpu_set_blendmode(bm_normal);
	}
}
//array_push(dynamic_assets, test_light);


var test_light = new static_asset(PLAYER.position.x, PLAYER.position.y, 0, 0, "light");
test_light.update_function = function(_self) {
	with (_self) {
		position.x = PLAYER.position.x;
		position.y = PLAYER.position.y-2;
	}
}
test_light.draw_function = function(_self) {
	with (_self) {
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(soft_round_vision, 0, position.x, position.y+5, .45, .45, 0, c_blue, .2);		
		gpu_set_blendmode(bm_normal);
	}
}
//array_push(dynamic_assets, test_light);

#endregion