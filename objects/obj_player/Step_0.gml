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
	
	var move_speed = character_main.stats.speed;
    var steps = max(1, ceil(move_speed / 4));
    
    for (var i = 0; i < steps; i++) {
        var step_vector = move_vector.Copy();
        step_vector.Multiply(move_speed / steps);
        
		var new_position = position.Copy();
		new_position.Add(step_vector);
        
        if (is_position_walkable(new_position.x, new_position.y)) {
            // Free movement
            position.Set(new_position);
        } else {
            // Collision detected - try sliding along walls
            
            // Try horizontal movement only
            var slide_x_ok = is_position_walkable(new_position.x, position.y);
            // Try vertical movement only  
            var slide_y_ok = is_position_walkable(position.x, new_position.y);
            
            if (slide_x_ok && slide_y_ok) {
                // Both directions are clear, choose the one closer to original direction
                if (abs(step_vector.x) > abs(step_vector.y)) {
                    position.x = new_position.x; // Prefer horizontal
                } else {
                    position.y = new_position.y; // Prefer vertical
                }
            } else if (slide_x_ok) {
                // Only horizontal slide available
                position.x = new_position.x;
            } else if (slide_y_ok) {
                // Only vertical slide available
                position.y = new_position.y;
            } else {
                // Completely blocked - stop movement
                break;
            }
        }
    }
}

// update character
character_main.update();