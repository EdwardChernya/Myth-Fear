/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;

// set background
var layer_id = layer_get_id("Background");
var back_id = layer_background_get_id(layer_id);
switch (type) {
	case "dungeon":
		layer_background_sprite(back_id, dungeon_ground1);
		break;
}

// create static assets
place_rocks_simple(type);

// sort static assets for quick depth
if (array_length(static_assets)>0) sort_by_y(static_assets);
DEBUG.add($"{array_length(static_assets)} static assets placed", c_lime);