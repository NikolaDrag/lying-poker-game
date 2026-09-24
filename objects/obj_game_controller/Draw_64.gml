// 1. Background Dimmer (if switching or game over)
if (state == GAME_STATE.SWITCHING_TURN || game_over) {
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1.0);
}

// 2. Global Status (Top Left)
draw_set_halign(fa_left); // Essential safety reset
draw_set_valign(fa_top);

draw_set_color(c_yellow);
draw_text_transformed(20, 24, "LOG: " + event_log, 4, 4, 0);

draw_set_color(c_white);
// Move Active Player down so it doesn't touch the Log
draw_text_transformed(20, 160, "ACTIVE PLAYER: P" + string(current_turn + 1), 4, 4, 0);

// 3. Bet Info
if (current_bet.better_index != -1) { 
    draw_set_color(c_orange);
    var _b = current_bet;
    
    // Move this down to 220 so it's clearly below the Player info
    // Also use transformed so we can actually see it!
    var _cat_name = hand_names[_b.category];
	var _bet_string = "CURRENT BET: P" + string(_b.better_index + 1) + " - " + _cat_name + " (Val: " + string(_b.value1) + ")";
    draw_text_transformed(20, 300, _bet_string, 4, 4, 0);
}
// 4. Center-Screen Notifications
draw_set_halign(fa_center);
var _mid_x = display_get_gui_width() / 2;
var _mid_y = display_get_gui_height() / 2;

if (game_over) {
    draw_set_color(c_red);
    draw_text_transformed(_mid_x, _mid_y, "GAME OVER", 6, 6, 0);
    draw_text_transformed(_mid_x, _mid_y + 240, "Press 'R' to Restart", 4, 4, 0);
} 
else if (state == GAME_STATE.SWITCHING_TURN) {
    draw_set_color(c_aqua);
    draw_text_transformed(_mid_x, _mid_y, "NEXT TURN: PLAYER " + string(current_turn + 1), 6, 6, 0);
    draw_text_transformed(_mid_x, _mid_y + 240, "PASS KEYBOARD & PRESS SPACE", 4, 4, 0);
}
draw_set_halign(fa_left); // Reset alignment!

// Low in the purple area so a full hand of cards does not cover them.
if (state == GAME_STATE.WAITING_FOR_INPUT && !game_over && !instance_exists(obj_pause_menu)) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(150, 210, 255));
    draw_rectangle(1500, 2680, 2450, 3110, false);
    draw_set_color(c_black);
    draw_text_transformed(1975, 2895, "BET", 5, 5, 0);

    draw_set_color(make_color_rgb(255, 170, 170));
    draw_rectangle(2550, 2680, 3700, 3110, false);
    draw_set_color(c_black);
    draw_text_transformed(3125, 2895, "CALL LIAR", 5, 5, 0);
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}

music_draw_buttons();