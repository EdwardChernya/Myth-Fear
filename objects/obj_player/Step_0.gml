/// @description Insert description here
// You can write your code in this editor

if (room != Room1) exit;

if (_touch_down() and !moving and mouse_inside_move_area()) {
	moving = true;
	current_action = "move";
	character_main.moving = true;
	move_start.Set(MOUSE);
}

// Handle movement
if (moving) {
	if (_touch_up()) {
		moving = false;
		character_main.moving = false;
		if (current_action == "move") current_action = "";
	}
	move_vector.Set(MOUSE);
	move_vector.Subtract(move_start);
	move_vector.Normalize();
	move_vector.Multiply(character_main.stats.speed);
	
	position.Add(move_vector);
}

// update character
character_main.update();