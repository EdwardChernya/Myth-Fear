/// @description Insert description here
// You can write your code in this editor


if (PAUSED) exit;

for (var i=0; i<array_length(dynamic_assets); i++) {
	dynamic_assets[i].update();
}