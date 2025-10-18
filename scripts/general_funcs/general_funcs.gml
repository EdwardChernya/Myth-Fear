// math
function Vector2(_x=0, _y=_x) constructor {
	
	if (is_struct(_x)) {
		x = _x.x;
		y = _x.y;
	} else {
		x = _x;
		y = _y;
	}
	
	static Set = function(_x, _y=_x) {
		if (is_struct(_x)) {
			x = _x.x;
			y = _x.y;
		} else {
			x = _x;
			y = _y;
		}
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
	
	static from_angle = function(_angle) {
		var rad = degtorad(_angle);
		x = cos(rad);
		y = -sin(rad);
	}
	static vector_array_from_angle = function(_angle) {
		var rad = degtorad(_angle);
		return [cos(rad), -sin(rad)];
	}
	static vector_array_from_angle_grid = function(_angle) {
		var rad = degtorad(_angle);
		return [round(cos(rad)), round(-sin(rad))];
	}
	static to_target = function(_x, _y=_x) {
		if (is_struct(_x)) {
			var dir = _x.Copy();
		} else {
			var dir = new Vector2(_x, _y);
		}
		dir.Subtract(self);
		self.Set(dir);
	}
	
	static to_angle = function(){
		return radtodeg(arctan2(-y, x));
	}
	
	static Round = function() {
		x = round(x);
		y = round(y);
	}
	static Floor = function() {
		x = floor(x);
		y = floor(y);
	}
	static Ceil = function() {
		x = ceil(x);
		y = ceil(y);
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

function xscale_to_target(_struct, tar) {
	var vec = _struct.position.Copy();
	vec.Subtract(tar);
	if (sign(vec.x) != 0 && abs(vec.x) > .01) _struct.image_xscale = sign(vec.x);
}

function get_sine() {
	return abs(sin(get_timer()/1000000));
}

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
function move_w_collision(_vector, _struct) {
	var move_speed = _struct.stats.speed;
    var steps = max(1, ceil(move_speed / 2)); // adjust 2 for more steps at higher speeds
    var _position = _struct.position;
	var _grid_pos = _struct.grid_position;
	var _prev_grid_pos = _struct.prev_grid_position;
	
    for (var i = 0; i < steps; i++) {
        var step_vector = _vector.Copy();
        step_vector.Multiply(move_speed / steps);
        
		var new_position = _position.Copy();
		new_position.Add(step_vector);
        
        if (is_position_walkable_dynamic(_struct, new_position.x, new_position.y)) {
            // Free movement
			xscale_to_target(_struct, new_position);
            _position.Set(new_position);
        } else {
			_struct.prev_move_vector = undefined;
            // Collision detected - try sliding along walls
            // Try horizontal movement only
            var slide_x_ok = is_position_walkable_dynamic(_struct, new_position.x, _position.y);
            // Try vertical movement only  
            var slide_y_ok = is_position_walkable_dynamic(_struct, _position.x, new_position.y);
            
            if (slide_x_ok && slide_y_ok) {
				xscale_to_target(_struct, new_position);
                // Both directions are clear, choose the one closer to original direction
                if (abs(step_vector.x) > abs(step_vector.y)) {
                    _position.x = new_position.x; // Prefer horizontal
                } else {
                    _position.y = new_position.y; // Prefer vertical
                }
            } else if (slide_x_ok) {
                // Only horizontal slide available
				xscale_to_target(_struct, new_position);
                _position.x = new_position.x;
            } else if (slide_y_ok) {
                // Only vertical slide available
				xscale_to_target(_struct, new_position);
                _position.y = new_position.y;
            } else {
                // Completely blocked - stop movement
                break;
            }
        }
    }
	
	_grid_pos.Set(to_grid(_position.x), to_grid(_position.y));
	if (_grid_pos.x != _prev_grid_pos.x || _grid_pos.y != _prev_grid_pos.y) {
		MAP.dynamic_grid[_grid_pos.x][_grid_pos.y] = _struct;
		MAP.dynamic_grid[_prev_grid_pos.x][_prev_grid_pos.y] = undefined;
		_prev_grid_pos.Set(_grid_pos);
		if (_struct.move_vector_skip <= 0) _struct.prev_move_vector = undefined;
		_struct.move_vector_skip -= 1;
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