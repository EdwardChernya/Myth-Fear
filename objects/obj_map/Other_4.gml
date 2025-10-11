/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;


randomize();
var r = irandom_range(MAP.size-MAP.size/3, MAP.size+MAP.size/3);
MAP.map_nodes = create_spiral_map(MAP.size*TILE, r, r*2);
DEBUG.add($"main {r} | total {array_length(MAP.map_nodes)}", c_lime);
	
init_grids();
	
PLAYER.position.Set(MAP.map_nodes[0]);
PLAYER.revealing_fog = 60;

if (!DEV) {
	CAMERA.x = PLAYER.position.x;
	CAMERA.y = PLAYER.position.y;
	var wide_res = max(CAMERA.width, CAMERA.height);
	CAMERA.zoom = max(2, ceil(wide_res/room_width));
	CAMERA.smooth_zoom = CAMERA.default_zoom;
}

// set background
var layer_id = layer_get_id("Background");
var back_id = layer_background_get_id(layer_id);

switch (type) {
	case "dungeon":
		// create static assets
		place_rocks_simple(type);
		place_connected_walls();
		place_edge_walls();
		pad_edges();
		
		generate_background_surfaces();
		generate_fog_surfaces();
		
		place_main_assets();
		
		layer_background_sprite(back_id, dungeon_ground1);
		break;
}


// sort static assets for quick depth
var number_of_assets = 0;
for (var xx =0; xx < array_length(static_assets); xx++) {
	for (var yy =0; yy < array_length(static_assets[xx]); yy++) {
		if (static_assets[xx][yy] != undefined) number_of_assets++;
	}
}
DEBUG.add($"{number_of_assets} total static assets", c_lime);


// dynamic assets
array_push(dynamic_assets, PLAYER.character_main);