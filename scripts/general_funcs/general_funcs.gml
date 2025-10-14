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

// arrays
function array_clear(array, entry) {
	var _f = function(_element, _index) {
		return (_element == entry);
	}
	var _index = array_find_index(array, _f);
	if (_index != -1) {
		array_delete(array, _index, 1);
	}
}
function find_array_index(array, entry) {
	for (var i=0; i<array_length(array); i++) {
		if (array[i] == entry) return i;
	}
	return -1;
}

// wrappers

function _touch_down() {
	var touches = get_touches();
	for (var i = 0; i < array_length(touches); i++) {
	    var touch = touches[i];
	    if (touch.pressed) return touch;
	}
	return false;
}
function _touch_up() {
	var touches = get_touches();
	for (var i = 0; i < array_length(touches); i++) {
	    var touch = touches[i];
	    if (touch.released) return touch;
	}
	return false;
}


function to_screen(_x, _y) {
	var sx = (_x-CAMERA.x)*CAMERA.zoom+CAMERA.width/2;
	var sy = (_y-CAMERA.y)*CAMERA.zoom+CAMERA.height/2;
	return new Vector2(sx, sy);
}
function to_world(_x, _y) {
	var wx = (_x-CAMERA.width/2)/CAMERA.zoom + CAMERA.x;
	var wy = (_y-CAMERA.height/2)/CAMERA.zoom + CAMERA.y;
	return new Vector2(wx, wy);
}

//stuff
function draw_rectangle_width_color(x1, y1, x2, y2, width, color) {
	var offset = floor(width/2);
	x1 = floor(x1);
	y1 = floor(y1);
	x2 = floor(x2);
	y2 = floor(y2);
	draw_line_width_color(x1, y1+offset, x2, y1+offset, width, color, color);
	draw_line_width_color(x2-offset, y1, x2-offset, y2, width, color, color);
	draw_line_width_color(x2, y2-offset, x1, y2-offset, width, color, color);
	draw_line_width_color(x1+offset, y2, x1+offset, y1, width, color, color);
}

function array_slice(source, source_index, length) {
	var sliced_array = [];
	array_copy(sliced_array, 0, source, source_index, length);
	return sliced_array;
}

function floating_text_manager() constructor {
	
	text_array = [];
	x = 0;
	y = .6;
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
			draw_text(x, CAMERA.height*y - i*24, text_array[i].text);
		}
		draw_set_alpha(1);
	}
}

function sort_by_y(array) {
	if (array_length(array) > 0) array_sort(array, function(a, b) { return a.position.y - b.position.y; });
}

function point_in_ellipse(px, py, center_x, center_y, radius, height_ratio) {
    // Calculate the actual y-radius based on height ratio
    var actual_radius_y = radius * height_ratio;
    
    // Ellipse equation: ((x-h)²/a²) + ((y-k)²/b²) <= 1
    var dx = (px - center_x) / radius;
    var dy = (py - center_y) / actual_radius_y;
    
    return (dx * dx + dy * dy) <= 1;
}

function normalize(value, min_val, max_val) {
    return (value - min_val) / (max_val - min_val);
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



// collision
function is_collision_shape_edge(grid, _x, _y) {
	var hedgeR=true, hedgeL=true, vedgeU=true, vedgeD=true;
	// check for horizontal edge both ways
	for (var i = _x; i < array_length(grid); i++) {
		if (grid[i][_y] == "free" && i != _x) hedgeR=false;
	}
	for (var i = _x; i > 0; i--) {
		if (grid[i][_y] == "free" && i != _x) hedgeL=false;
	}
	// check for vertical edge both ways
	for (var i = _y; i < array_length(grid); i++) {
		if (grid[_x][i] == "free" && i != _y) vedgeD=false;
	}
	for (var i = _y; i > 0; i--) {
		if (grid[_x][i] == "free" && i != _y) vedgeU=false;
	}
	
	var is_edge = (hedgeR or hedgeL or vedgeU or vedgeD);
	return { is_edge : is_edge, hedgeR : hedgeR, hedgeL : hedgeL, vedgeU : vedgeU, vedgeD : vedgeD};
}

function to_grid(_p, _cell_size=MAP.collision_grid_cell_size, _grid_size=MAP.collision_grid_size) {
	return clamp(floor(_p/_cell_size), 0, _grid_size-1);
}


// devices and touches

function get_touches() {
    var touches = [];
    var max_touches = 3; // Most phones support up to 5 touches
    
    for (var i = 0; i < max_touches; i++) {
        if (device_mouse_check_button(i, mb_left) || device_mouse_check_button_released(i, mb_left)) {
            array_push(touches, {
                id: i,
                x: device_mouse_x(i),
                y: device_mouse_y(i),
				guix: device_mouse_raw_x(i),
				guiy: device_mouse_raw_y(i),
                pressed: device_mouse_check_button_pressed(i, mb_left),
                released: device_mouse_check_button_released(i, mb_left)
            });
        }
    }
    
    return touches;
}

function press_in_rectangle(area) {
	var touches = get_touches();
	for (var i = 0; i < array_length(touches); i++) {
	    var touch = touches[i];
	    if (touch.pressed && point_in_rectangle(touch.guix, touch.guiy, area.x, area.y, area.x2, area.y2)) return true;
	}
	return false;
}