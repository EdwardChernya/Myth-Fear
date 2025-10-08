// math
function Vector2(_x=0, _y=_x) constructor {
	x = _x;
	y = _y;
	
	static Set = function(_other) {
		x = _other.x;
		y = _other.y;
	}
	
	static Normalize = function() {
        var len = Length();
        if (len > 0) {
            x /= len;
			y /= len;
        } else {
			x = 0;
			y = 0;
		}
    }
    
    static Length = function() {
        return sqrt(x * x + y * y);
    }
	
	static Add = function(_other) {
        x += _other.x;
		y += _other.y;
    }
    
    static Subtract = function(_other) {
        x -= _other.x;
		y -= _other.y;
    }
	
	static Multiply = function(scalar) {
        x *= scalar;
		y *= scalar;
    }
    
    static Divide = function(scalar) {
        if (scalar != 0) {
            x /= scalar;
			y /= scalar;
        } else {
			x = 0;
			y = 0;
		}
    }
	
	static Dot = function(_other) {
        return (x * _other.x + y * _other.y);
    }
	
	static Distance = function(_other) {
        var dx = x - _other.x;
        var dy = y - _other.y;
        return sqrt(dx * dx + dy * dy);
    }
	
	static Copy = function() {
		return new Vector2(x, y);
	}
}

// wrappers

function _touch_down() {
	return mouse_check_button_pressed(mb_left);
}
function _touch_up() {
	return mouse_check_button_released(mb_left);
}
function _touch_hold() {
	return mouse_check_button(mb_left);
}


//stuff 

function mouse_inside_move_area() {
	if (point_in_rectangle(MOUSE.x, MOUSE.y, CAMERA.width*PLAYER.move_area.x, CAMERA.height*PLAYER.move_area.y, CAMERA.width, CAMERA.height)) {
		return true;
	}
	return false;
}

function floating_text_manager() constructor {
	
	text_array = [];
	max_lines = 2000;
	max_lines_visible = 30;
	visible = true;
	
	static add = function(_text, _color) {
		array_insert(text_array, 0, { text : _text, color : _color, life : 60*5});
	}
	
	static update = function() {
		for (var i=0; i < array_length(text_array); i++) {
			text_array[i].life -= 1;
		}
		while (array_length(text_array) > max_lines) {
			array_delete(text_array, array_length(text_array)-1, 1);
		}
		max_lines_visible = floor((CAMERA.height*.6 - 64)/24 - 1);
	}
	
	static draw = function() {
		draw_set_halign(fa_left);
		draw_set_valign(fa_bottom);
		for (var i=0; i < array_length(text_array); i++) {
			if (i > max_lines_visible) break;
			draw_set_color(text_array[i].color);
			draw_set_alpha(text_array[i].life/60);
			if (DEV) draw_set_alpha(1);
			draw_text(0, CAMERA.height*.6 - i*24, text_array[i].text);
		}
		draw_set_alpha(1);
	}
}

function sort_by_y(array) {
	array_sort(array, function(a, b) { return a.y - b.y; });
}

// moving
function move_w_collision(_speed, _vector, _position) {
	var move_speed = _speed/3;
    var steps = max(1, ceil(move_speed / 2)); // adjust 2 for more steps at higher speeds
    
    for (var i = 0; i < steps; i++) {
        var step_vector = _vector.Copy();
        step_vector.Multiply(move_speed / steps);
        
		var new_position = _position.Copy();
		new_position.Add(step_vector);
        
        if (is_position_walkable(new_position.x, new_position.y)) {
            // Free movement
            _position.Set(new_position);
        } else {
            // Collision detected - try sliding along walls
            // Try horizontal movement only
            var slide_x_ok = is_position_walkable(new_position.x, _position.y);
            // Try vertical movement only  
            var slide_y_ok = is_position_walkable(_position.x, new_position.y);
            
            if (slide_x_ok && slide_y_ok) {
                // Both directions are clear, choose the one closer to original direction
                if (abs(step_vector.x) > abs(step_vector.y)) {
                    _position.x = new_position.x; // Prefer horizontal
                } else {
                    _position.y = new_position.y; // Prefer vertical
                }
            } else if (slide_x_ok) {
                // Only horizontal slide available
                _position.x = new_position.x;
            } else if (slide_y_ok) {
                // Only vertical slide available
                _position.y = new_position.y;
            } else {
                // Completely blocked - stop movement
                break;
            }
        }
    }
}