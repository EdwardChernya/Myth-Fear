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
	
	static add = function(_text, _color) {
		array_insert(text_array, 0, { text : _text, color : _color, life : 60*5});
	}
	
	static update = function() {
		for (var i=0; i < array_length(text_array); i++) {
			text_array[i].life -= 1;
		}
		while (array_length(text_array) > 0 and text_array[array_length(text_array)-1].life <= 0) {
			array_delete(text_array, array_length(text_array)-1, 1);
		}
	}
	
	static draw = function() {
		draw_set_halign(fa_left);
		draw_set_valign(fa_bottom);
		for (var i=0; i < array_length(text_array); i++) {
			draw_set_color(text_array[i].color);
			draw_set_alpha(text_array[i].life/60);
			draw_text(0, CAMERA.height*.6 - i*24, text_array[i].text);
		}
		draw_set_alpha(1);
	}
}