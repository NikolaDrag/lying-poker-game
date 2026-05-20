var _gx = device_mouse_x_to_gui(0);
var _gy = device_mouse_y_to_gui(0);

var _v1_min = 1;
var _v1_max = 13;
if (temp_cat == POKER_HAND.FLUSH) {
    _v1_min = 0;
    _v1_max = 3;
} else if (temp_cat == POKER_HAND.STRAIGHT || temp_cat == POKER_HAND.STRAIGHT_FLUSH) {
    _v1_min = 1;
    _v1_max = 10;
}

var _use_v2 = false;
var _v2_min = 1;
var _v2_max = 13;
if (temp_cat == POKER_HAND.TWO_PAIR || temp_cat == POKER_HAND.FULL_HOUSE) {
    _use_v2 = true;
} else if (temp_cat == POKER_HAND.STRAIGHT_FLUSH) {
    _use_v2 = true;
    _v2_min = 0;
    _v2_max = 3;
}

if (temp_v1 < _v1_min || temp_v1 > _v1_max) temp_v1 = _v1_min;
if (_use_v2) {
    if (temp_v2 < _v2_min || temp_v2 > _v2_max) temp_v2 = _v2_min;
} else {
    temp_v2 = 0;
}

// --- 1. ONLY ENTER CONFIRMS ---
if (keyboard_check_pressed(vk_enter)) confirm_bet();

if (mouse_check_button_pressed(mb_left)) {
    
    // --- CATEGORY SCROLLING ---
    // Sprite is 1280 wide. Let's say the arrows live in the outer 300 pixels on each side.
    if (point_in_rectangle(_gx, _gy, ui_x[0]-640, ui_y-160, ui_x[0]+640, ui_y+160)) {
        if (_gx < ui_x[0] - 300) {      // Clicked the LEFT side (Up Arrow)
            if (temp_cat < 9) temp_cat++;
        } 
        else if (_gx > ui_x[0] + 300) { // Clicked the RIGHT side (Down Arrow)
            if (temp_cat > 0) temp_cat--;
        }
        // Middle click does nothing now!
    }

    // --- VALUE 1 SCROLLING ---
    // Sprite is 800 wide. Arrows live in the outer 200 pixels.
    if (point_in_rectangle(_gx, _gy, ui_x[1]-400, ui_y-160, ui_x[1]+400, ui_y+400)) {
        if (_gx < ui_x[1] - 150) {      // LEFT side
            temp_v1++;
            if (temp_v1 > _v1_max) temp_v1 = _v1_min;
        }
        else if (_gx > ui_x[1] + 150) { // RIGHT side
            temp_v1--;
            if (temp_v1 < _v1_min) temp_v1 = _v1_max;
        }
    }

    // --- VALUE 2 SCROLLING ---
    if (_use_v2) {
        if (point_in_rectangle(_gx, _gy, ui_x[2]-400, ui_y-160, ui_x[2]+400, ui_y+160)) {
            if (_gx < ui_x[2] - 150) {  // LEFT side
                temp_v2++;
                if (temp_v2 > _v2_max) temp_v2 = _v2_min;
            }
            else if (_gx > ui_x[2] + 150) { // RIGHT side
                temp_v2--;
                if (temp_v2 < _v2_min) temp_v2 = _v2_max;
            }
        }
    }
}