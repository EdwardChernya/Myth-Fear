/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;

if (_touch_down() and !character_main.moving and mouse_inside_move_area()) {
	current_action = "move";
	character_main.moving = true;
	move_start.Set(MOUSE);
}

// Handle movement
if (character_main.moving) {
	if (_touch_up()) {
		character_main.moving = false;
		if (current_action == "move") current_action = "";
	}
	move_vector.Set(MOUSE);
	move_vector.Subtract(move_start);
	move_vector.Normalize();
	
	move_w_collision(character_main.stats.speed, move_vector, position);

}

// update character
character_main.update();