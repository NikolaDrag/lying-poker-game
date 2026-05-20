// Draw GUI Event
var _cb = obj_game_controller.current_bet;

// 1. Determine if the current "Temp" selection is a valid raise
var _is_valid = obj_game_controller.is_bet_valid_increase(temp_cat, temp_v1, temp_v2);
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
    draw_sprite_ext(spr_bet_value, temp_v2 - 1, ui_x[2], ui_y, 1, 1, 0, _color, 1);//-1 zaradi frame ot 0
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
var _txt = _is_valid ? "PRESS ENTER TO CONFIRM BET" : "INCREASE BET TO CONTINUE";

// Now draw it with 5x scale so it's readable at 5000x3500 resolution
draw_text_transformed(2500, 2000, _txt, 5, 5, 0);

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