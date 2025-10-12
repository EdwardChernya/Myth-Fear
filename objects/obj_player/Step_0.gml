/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;


right_area = { x : CAMERA.width*.5, y : CAMERA.height*.6, x2 : CAMERA.width, y2 : CAMERA.height };
left_area = { x : 0, y: CAMERA.height*.6, x2 : CAMERA.width*.5, y2: CAMERA.height};

if (PAUSED) exit;

if (press_in_rectangle(right_area) and !character_main.moving) {
	current_action = "move";
	character_main.moving = true;
	move_start.Set(MOUSE);
}

// Handle movement
if (character_main.moving) {
	revealing_fog = 60;
	if (_touch_up() != false) {
		character_main.moving = false;
		if (current_action == "move") current_action = "";
	}
	move_vector.Set(MOUSE);
	move_vector.Subtract(move_start);
	move_vector.Normalize();
	
	move_w_collision(character_main.stats.speed, move_vector, position);

}
if (revealing_fog > 0) revealing_fog -= 1;

// update character
reveal_fog(position.x, position.y, character_main.stats.vision, .67);


if (press_in_rectangle(left_area)) destroy_circle_area(position.x, position.y, 100);


if (keyboard_check_pressed(ord("A"))) instance_create_layer(mouse_x, mouse_y, "Instances", o_dungeon_tent, {image_xscale : 1});

//if (keyboard_check_pressed(ord("Q"))) destroy_square_area_grid(to_grid(mouse_x), to_grid(mouse_y), to_grid(mouse_x), to_grid(mouse_y));