// Draw GUI Event. Hidden while paused so those controls cannot cover the menu.
if (instance_exists(obj_pause_menu)) exit;

var _cb = obj_game_controller.current_bet;

// 1. Determine if the current "Temp" selection is a valid raise
var _same_rank = (temp_cat == POKER_HAND.TWO_PAIR || temp_cat == POKER_HAND.FULL_HOUSE) && (temp_v1 == temp_v2);
var _is_valid = obj_game_controller.is_bet_valid_increase(temp_cat, temp_v1, temp_v2) && !_same_rank;
var _color = _is_valid ? c_white : c_gray; // Dim it if it's not a valid raise yet

// 2. Draw Category Selector
// We use draw_sprite_ext so we can change the color/alpha
draw_sprite_ext(spr_bet_category, temp_cat, ui_x[0], ui_y, 1, 1, 0, _color, 1);

// 3. Draw Value 1 Selector
if (temp_cat == POKER_HAND.FLUSH) {
    var _suit_name = "Diamonds";
    switch (temp_v1) {
        case SUIT.HEARTS: _suit_name = "Hearts"; break;
        case SUIT.SPADES: _suit_name = "Spades"; break;
        case SUIT.CLUBS: _suit_name = "Clubs"; break;
    }
    draw_set_halign(fa_center);
    draw_set_color(_color);
    draw_text_transformed(ui_x[1], ui_y, _suit_name, 4, 4, 0);
} else {
    draw_sprite_ext(spr_bet_value, temp_v1 - 1, ui_x[1], ui_y, 1, 1, 0, _color, 1);//-1 zaradi frame ot 0
}

// 4. Draw Value 2 (Only if Two Pair [2] or Full House [5])
if (temp_cat == POKER_HAND.TWO_PAIR || temp_cat == POKER_HAND.FULL_HOUSE) {
    // The rank already used on the left is blurred so it cannot be the second pair.
    var _v2_color = _same_rank ? c_gray : _color;
    var _v2_alpha = _same_rank ? 0.35 : 1;
    draw_sprite_ext(spr_bet_value, temp_v2 - 1, ui_x[2], ui_y, 1, 1, 0, _v2_color, _v2_alpha);
    draw_set_alpha(1);
} else if (temp_cat == POKER_HAND.STRAIGHT_FLUSH) {
    var _suit_name2 = "Diamonds";
    switch (temp_v2) {
        case SUIT.HEARTS: _suit_name2 = "Hearts"; break;
        case SUIT.SPADES: _suit_name2 = "Spades"; break;
        case SUIT.CLUBS: _suit_name2 = "Clubs"; break;
    }
    draw_set_halign(fa_center);
    draw_set_color(_color);
    draw_text_transformed(ui_x[2], ui_y, _suit_name2, 4, 4, 0);
}

// 5. Instruction Text
draw_set_color(c_white);
draw_set_halign(fa_center);
var _txt = _is_valid ? "CLICK END TURN" : "INCREASE BET TO CONTINUE";

// Now draw it with 5x scale so it's readable at 5000x3500 resolution
draw_text_transformed(2500, 2000, _txt, 6.5, 6.5, 0);

draw_set_valign(fa_middle);
if (_is_valid) draw_set_color(c_green);
else draw_set_color(c_dkgray);
draw_rectangle(hit_end_turn[0], hit_end_turn[1], hit_end_turn[2], hit_end_turn[3], false);
draw_set_color(c_white);
draw_rectangle(hit_end_turn[0], hit_end_turn[1], hit_end_turn[2], hit_end_turn[3], true);
draw_text_transformed((hit_end_turn[0] + hit_end_turn[2]) * 0.5, (hit_end_turn[1] + hit_end_turn[3]) * 0.5, "END TURN", 4, 4, 0);
draw_set_valign(fa_top);

// --- DEBUG HITBOXES ---
// --- UPDATED DEBUG HITBOXES ---
// --- UPDATED DEBUG HITBOXES ---
draw_set_alpha(0.3);
draw_set_color(c_red);
// Category End Zones (Left and Right only)
draw_rectangle(ui_x[0]-640, ui_y-160, ui_x[0]-300, ui_y+160, false); // Left
draw_rectangle(ui_x[0]+300, ui_y-160, ui_x[0]+640, ui_y+160, false); // Right

draw_set_color(c_blue);
// Value 1 End Zones
draw_rectangle(ui_x[1]-400, ui_y-160, ui_x[1]-150, ui_y+160, false); // Left
draw_rectangle(ui_x[1]+150, ui_y-160, ui_x[1]+400, ui_y+160, false); // Right
draw_set_alpha(1.0);