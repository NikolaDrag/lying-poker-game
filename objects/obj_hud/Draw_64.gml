/// Table card counts, the claim in words, the bluff reveal, and the key hints.
/// Drawn on the GUI layer so it sits over the table without moving any sprites.

if (!instance_exists(obj_game_controller)) exit;
var _ctrl = obj_game_controller;

draw_set_alpha(1);
draw_set_valign(fa_top);
draw_set_halign(fa_left);

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
// Just left of the right-aligned LAST BETS column.
var _x = _gui_w - 1680;
var _y = 24;

draw_set_color(c_aqua);
draw_text_transformed(_x, _y, "TABLE", 4.6, 4.6, 0);

for (var i = 0; i < _ctrl.num_players; i++) {
	var _n = array_length(_ctrl.hands[i]);
	var _line = seat_name(i) + ": " + string(_n);
	_line += (_n == 1) ? " card" : " cards";
	if (!_ctrl.alive[i]) {
		_line += "  OUT";
		draw_set_color(c_gray);
	} else if (i == _ctrl.current_turn && !_ctrl.game_over) {
		_line += "  <";
		draw_set_color(c_yellow);
	} else {
		draw_set_color(c_white);
	}
	draw_text_transformed(_x, _y + 120 + (i * 105), _line, 3.6, 3.6, 0);
}

// Newest claim on top, pinned to the right edge beside the table.
draw_set_halign(fa_right);
var _bets_x = _gui_w - 36;
draw_set_color(c_orange);
draw_text_transformed(_bets_x, _y, "LAST BETS", 4, 4, 0);
if (array_length(_ctrl.bet_log) == 0) {
	draw_set_color(c_white);
	draw_text_transformed(_bets_x, _y + 110, "No bets yet.", 3.3, 3.3, 0);
} else {
	var _logged = array_length(_ctrl.bet_log);
	for (var b = 0; b < _logged; b++) {
		draw_set_color(c_white);
		draw_text_transformed(_bets_x, _y + 110 + (b * 95), _ctrl.bet_log[_logged - 1 - b], 3.3, 3.3, 0);
	}
}
draw_set_halign(fa_left);

var _mid_x = _gui_w * 0.5;
var _mid_y = _gui_h * 0.5;

if (_ctrl.game_over) {
	draw_set_halign(fa_center);
	draw_set_color(c_lime);
	var _win = "NOBODY LEFT";
	if (_ctrl.winner_index == 0) _win = "YOU WIN";
	else if (_ctrl.winner_index > 0) _win = seat_name(_ctrl.winner_index) + " WINS";
	draw_text_transformed(_mid_x, _mid_y + 420, _win, 6, 6, 0);
}

var _show_reveal = _ctrl.reveal_pending || (_ctrl.game_over && array_length(_ctrl.reveal_lines) > 0);
if (_show_reveal) {
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_mid_x, _mid_y + 620, _ctrl.reveal_header, 3.1, 3.1, 0);
	draw_set_color(c_white);
	for (var r = 0; r < array_length(_ctrl.reveal_lines); r++) {
		draw_text_transformed(_mid_x, _mid_y + 780 + (r * 110), _ctrl.reveal_lines[r], 2.7, 2.7, 0);
	}
}

draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text_transformed(_mid_x, _gui_h - 200, control_hint(_ctrl), 3.6, 3.6, 0);
draw_text_transformed(_mid_x, _gui_h - 100, "Esc: menu", 3.2, 3.2, 0);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
