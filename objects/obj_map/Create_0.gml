/// @description Insert description here
// You can write your code in this editor

map_name = "none";

size = 64;
map_nodes = undefined;
last_node = undefined;
node_size = 100;
world = undefined;

big_areas = undefined;
remote_areas = undefined;
remote_areas_pass2 = undefined;
left_over_areas = undefined;

fog_grid = undefined;

flow_field = undefined;
cost_field = undefined;

collision_scale = 4;
collision_grid = undefined;
collision_grid_size = undefined;
collision_grid_cell_size = undefined;

cull_start_x = 0;
cull_start_y = 0;
cull_end_x = 0;
cull_end_y = 0;

dynamic_grid = undefined;

dynamic_assets = [];
culled_array = [];
interact_array = [];

static_assets = [];
assets_grid = undefined;

back_id = undefined;
background_surfaces = undefined;
background_surface_size = 1024;
surfaces_per_row = 0;

play_min_x = undefined;
play_min_y = undefined;
play_max_x = undefined;
play_max_y = undefined;

fog_revealed_alpha = 0.55;
fog_grid = undefined;
fog_sprite_index = 0;
background_fog_surfaces = undefined;
permafog_surfaces = undefined;
fog_surfaces = undefined;




// draw dev visuals
draw_collision = false;
draw_dynamic = false;
draw_asset = false;
draw_nodes = false;
draw_areas = false;
draw_flow = false;

#region assets
dungeon_rocks =  [
	{sprite: dungeon_rock_s,   size: 30},
	{sprite: dungeon_rock_s2,  size: 30}, 
	{sprite: dungeon_rock_s3,  size: 30},
	{sprite: dungeon_rock_s5,  size: 30},
	{sprite: dungeon_rock_s6,  size: 30},
	{sprite: dungeon_rock_s7,  size: 30},
	{sprite: dungeon_rock_s8,  size: 30},
	{sprite: dungeon_rock_s9,  size: 30},
	{sprite: dungeon_rock_s10,  size: 30},
	{sprite: dungeon_rock_s11,  size: 30},
	{sprite: dungeon_rock_s12,  size: 30},
	{sprite: dungeon_rock_s13,  size: 30},
	{sprite: dungeon_rock_s14,  size: 30},
	{sprite: dungeon_rock_s15,  size: 30},
	{sprite: dungeon_rock_s16,  size: 30},
	{sprite: dungeon_rock_s17,  size: 30},
	{sprite: dungeon_rock_s18,  size: 30},
	{sprite: dungeon_rock_s19,  size: 30},
	{sprite: dungeon_rock_s20,  size: 30},
	{sprite: dungeon_rock_m,   size: 30},
];
#endregion