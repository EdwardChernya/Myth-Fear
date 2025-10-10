/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;

// set background
var layer_id = layer_get_id("Background");
var back_id = layer_background_get_id(layer_id);
MAP.static_assets = [];
switch (type) {
	case "dungeon":
		// create static assets
		place_rocks_simple(type);
		place_connected_walls();
		place_edge_walls();
		generate_background_surfaces();
		generate_fog_surfaces();
		
		place_main_assets();
		
		layer_background_sprite(back_id, dungeon_ground1);
		break;
}


// sort static assets for quick depth
if (array_length(static_assets)>0) sort_by_y(static_assets);
DEBUG.add($"{array_length(static_assets)} total static assets", c_lime);


// dynamic assets
array_push(MAP.dynamic_assets, PLAYER.character_main);