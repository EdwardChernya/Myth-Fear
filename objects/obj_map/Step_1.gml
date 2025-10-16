/// @description Insert description here
// You can write your code in this editor


if (PAUSED || room != Room1) exit;

for (var i=0; i<array_length(dynamic_assets); i++) {
	dynamic_assets[i].update_begin();
}


for (var i=0; i<array_length(interact_array); i++) {
	interact_array[i].update_begin();
}


