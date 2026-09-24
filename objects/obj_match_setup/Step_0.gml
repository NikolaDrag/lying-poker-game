if (!mouse_check_button_pressed(mb_left)) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

if (point_in_rectangle(_mx, _my, hit_players_up[0], hit_players_up[1], hit_players_up[2], hit_players_up[3])) {
	if (players < 7) {
		var _filled = (bots == players - 1);
		players += 1;
		if (_filled) bots = players - 1;
	}
} else if (point_in_rectangle(_mx, _my, hit_players_down[0], hit_players_down[1], hit_players_down[2], hit_players_down[3])) {
	if (players > 2) {
		var _filled = (bots == players - 1);
		players -= 1;
		if (_filled) bots = players - 1;
	}
} else if (point_in_rectangle(_mx, _my, hit_bots_up[0], hit_bots_up[1], hit_bots_up[2], hit_bots_up[3])) {
	if (bots < players - 1) bots += 1;
} else if (point_in_rectangle(_mx, _my, hit_bots_down[0], hit_bots_down[1], hit_bots_down[2], hit_bots_down[3])) {
	if (bots > 0) bots -= 1;
} else if (point_in_rectangle(_mx, _my, hit_out_up[0], hit_out_up[1], hit_out_up[2], hit_out_up[3])) {
	if (out_at < max_out_at(players)) out_at += 1;
} else if (point_in_rectangle(_mx, _my, hit_out_down[0], hit_out_down[1], hit_out_down[2], hit_out_down[3])) {
	if (out_at > 2) out_at -= 1;
} else if (point_in_rectangle(_mx, _my, hit_start[0], hit_start[1], hit_start[2], hit_start[3])) {
	global.match_players = players;
	global.match_bots = bots;
	global.match_out_at = out_at;
	room_goto(Room1);
	exit;
} else if (point_in_rectangle(_mx, _my, hit_back[0], hit_back[1], hit_back[2], hit_back[3])) {
	instance_destroy();
	exit;
}

if (out_at > max_out_at(players)) out_at = max_out_at(players);
if (out_at < 2) out_at = 2;
if (bots > players - 1) bots = players - 1;
if (bots < 0) bots = 0;
