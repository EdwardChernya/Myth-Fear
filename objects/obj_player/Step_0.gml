/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;


right_area = { x : CAMERA.width*.5, y : CAMERA.height*.6, x2 : CAMERA.width, y2 : CAMERA.height };
left_area = { x : 0, y: CAMERA.height*.6, x2 : CAMERA.width*.5, y2: CAMERA.height};

if (PAUSED) exit;

#region inputs

if (press_in_rectangle(right_area)) {
	PLAYER.change_state(PLAYER.move);
	move_start.Set(MOUSE);
}

// Handle movement
if (PLAYER.state == PLAYER.move) {
	revealing_fog = 60;
	if (_touch_up() != false) {
		PLAYER.state.state_has_ended = true;
	}
	move_vector.Set(MOUSE);
	move_vector.Subtract(move_start);
	move_vector.Normalize();
	
	move_w_collision(move_vector, PLAYER);
	
}
#endregion

// set this obj position to the hero position for dev stuff below
position.Set(PLAYER.position);


//if (press_in_rectangle(left_area)) destroy_circle_area(PLAYER.position.x, PLAYER.position.y, 100);


if (keyboard_check_pressed(ord("A"))) instance_create_layer(mouse_x, mouse_y, "Instances", choose(o_dungeon_relic, o_dungeon_lantern), {image_xscale : 1});

//if (keyboard_check_pressed(ord("Q"))) destroy_square_area_grid(to_grid(mouse_x), to_grid(mouse_y), to_grid(mouse_x), to_grid(mouse_y));

if (keyboard_check_pressed(ord("S"))) {
	var vec = new Vector2(mouse_x, mouse_y);
	vec.to_target(PLAYER.position);
	vec.Normalize();
	vec.Multiply(2);
	PLAYER.cape.add_force(vec);
}