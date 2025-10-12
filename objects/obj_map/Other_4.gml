/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;



// get background layer id
var layer_id = layer_get_id("Background");
back_id = layer_background_get_id(layer_id);

// generate map
generate_map(world);
DEBUG.add($"main {r} | total {array_length(MAP.map_nodes)}", c_lime);

// sort static assets for quick depth
var number_of_assets = 0;
for (var xx =0; xx < array_length(static_assets); xx++) {
	for (var yy =0; yy < array_length(static_assets[xx]); yy++) {
		if (static_assets[xx][yy] != undefined) number_of_assets++;
	}
}
DEBUG.add($"{number_of_assets} total static assets", c_lime);




// setup camera and player
PLAYER.position.Set(MAP.map_nodes[0]);
PLAYER.revealing_fog = 60;

if (!DEV) {
	CAMERA.x = PLAYER.position.x;
	CAMERA.y = PLAYER.position.y;
	var wide_res = max(CAMERA.width, CAMERA.height);
	CAMERA.zoom = max(2, ceil(wide_res/room_width));
	CAMERA.smooth_zoom = CAMERA.default_zoom;
}

// dynamic assets
dynamic_assets = [];
array_push(dynamic_assets, PLAYER.character_main);