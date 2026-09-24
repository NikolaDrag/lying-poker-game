if (panel_mode == "options") {
	draw_set_alpha(0.72);
	draw_set_color(c_black);
	draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	draw_set_alpha(1);

	draw_set_color(make_color_rgb(18, 28, 24));
	draw_rectangle(1300, 620, 3700, 3050, false);
	draw_set_color(c_white);
	draw_rectangle(1300, 620, 3700, 3050, true);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_yellow);
	draw_text_transformed(2500, 820, "OPTIONS", 5, 5, 0);

	draw_set_color(c_white);
	draw_text_transformed(2500, 1080, "MUSIC", 3.2, 3.2, 0);

	if (variable_global_exists("music_on") && global.music_on) draw_set_color(c_green);
	else draw_set_color(c_maroon);
	draw_rectangle(hit_music[0], hit_music[1], hit_music[2], hit_music[3], false);
	draw_set_color(c_white);
	draw_rectangle(hit_music[0], hit_music[1], hit_music[2], hit_music[3], true);
	var _music_word = "MUSIC OFF";
	if (variable_global_exists("music_status")) _music_word = "MUSIC " + global.music_status;
	else if (variable_global_exists("music_on") && global.music_on) _music_word = "MUSIC ON";
	draw_text_transformed(2500, (hit_music[1] + hit_music[3]) * 0.5, _music_word, 4, 4, 0);

	draw_set_color(c_ltgray);
	draw_text_transformed(2500, 1900, "Click the button to turn the song on or off.", 2.2, 2.2, 0);

	draw_set_color(c_maroon);
	draw_rectangle(hit_back[0], hit_back[1], hit_back[2], hit_back[3], false);
	draw_set_color(c_white);
	draw_text_transformed(2500, (hit_back[1] + hit_back[3]) * 0.5, "BACK", 3, 3, 0);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	exit;
}

draw_set_alpha(0.72);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

draw_set_color(make_color_rgb(18, 28, 24));
draw_rectangle(1300, 620, 3700, 3050, false);
draw_set_color(c_white);
draw_rectangle(1300, 620, 3700, 3050, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_yellow);
draw_text_transformed(2500, 820, "NEW GAME", 5, 5, 0);

draw_set_color(c_white);
draw_text_transformed(1700, 980, "PLAYERS", 3, 3, 0);
draw_text_transformed(2500, 980, "BOTS", 3, 3, 0);
draw_text_transformed(3300, 980, "OUT AT", 3, 3, 0);

draw_set_color(c_dkgray);
draw_rectangle(hit_players_up[0], hit_players_up[1], hit_players_up[2], hit_players_up[3], false);
draw_rectangle(hit_players_down[0], hit_players_down[1], hit_players_down[2], hit_players_down[3], false);
draw_rectangle(hit_bots_up[0], hit_bots_up[1], hit_bots_up[2], hit_bots_up[3], false);
draw_rectangle(hit_bots_down[0], hit_bots_down[1], hit_bots_down[2], hit_bots_down[3], false);
draw_rectangle(hit_out_up[0], hit_out_up[1], hit_out_up[2], hit_out_up[3], false);
draw_rectangle(hit_out_down[0], hit_out_down[1], hit_out_down[2], hit_out_down[3], false);
draw_set_color(c_white);
draw_rectangle(hit_players_up[0], hit_players_up[1], hit_players_up[2], hit_players_up[3], true);
draw_rectangle(hit_players_down[0], hit_players_down[1], hit_players_down[2], hit_players_down[3], true);
draw_rectangle(hit_bots_up[0], hit_bots_up[1], hit_bots_up[2], hit_bots_up[3], true);
draw_rectangle(hit_bots_down[0], hit_bots_down[1], hit_bots_down[2], hit_bots_down[3], true);
draw_rectangle(hit_out_up[0], hit_out_up[1], hit_out_up[2], hit_out_up[3], true);
draw_rectangle(hit_out_down[0], hit_out_down[1], hit_out_down[2], hit_out_down[3], true);

draw_text_transformed(1700, (hit_players_up[1] + hit_players_up[3]) * 0.5, "^", 4, 4, 0);
draw_text_transformed(1700, (hit_players_down[1] + hit_players_down[3]) * 0.5, "v", 4, 4, 0);
draw_text_transformed(2500, (hit_bots_up[1] + hit_bots_up[3]) * 0.5, "^", 4, 4, 0);
draw_text_transformed(2500, (hit_bots_down[1] + hit_bots_down[3]) * 0.5, "v", 4, 4, 0);
draw_text_transformed(3300, (hit_out_up[1] + hit_out_up[3]) * 0.5, "^", 4, 4, 0);
draw_text_transformed(3300, (hit_out_down[1] + hit_out_down[3]) * 0.5, "v", 4, 4, 0);

draw_set_color(c_aqua);
draw_text_transformed(1700, 1470, string(players), 5, 5, 0);
draw_text_transformed(2500, 1470, string(bots), 5, 5, 0);
draw_text_transformed(3300, 1470, string(out_at), 5, 5, 0);

draw_set_color(c_ltgray);
var _cap = max_out_at(players);
var _humans = players - bots;
draw_text_transformed(2500, 2060, "Out at " + string(out_at) + " cards. Deck allows up to " + string(_cap) + ".", 2.2, 2.2, 0);
draw_text_transformed(2500, 2180, "You are seat 1. Humans: " + string(_humans) + ". Bots take the last seats.", 2.2, 2.2, 0);

draw_set_color(c_green);
draw_rectangle(hit_start[0], hit_start[1], hit_start[2], hit_start[3], false);
draw_set_color(c_white);
draw_text_transformed(2500, (hit_start[1] + hit_start[3]) * 0.5, "START", 4, 4, 0);

draw_set_color(c_maroon);
draw_rectangle(hit_back[0], hit_back[1], hit_back[2], hit_back[3], false);
draw_set_color(c_white);
draw_text_transformed(2500, (hit_back[1] + hit_back[3]) * 0.5, "BACK", 3, 3, 0);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
