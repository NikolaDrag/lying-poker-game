/// Human-readable names for seats, claims, and the on-screen control hint.
/// The betting arrows and the poker enum order are not defined here.

function seat_name(_idx) {
	if (_idx == 0) return "You";
	return "P" + string(_idx + 1);
}

function rank_short(_v) {
	if (_v == 1) return "A";
	if (_v == 11) return "J";
	if (_v == 12) return "Q";
	if (_v == 13) return "K";
	return string(_v);
}

function rank_plural(_v) {
	if (_v == 1) return "Aces";
	if (_v == 11) return "Jacks";
	if (_v == 12) return "Queens";
	if (_v == 13) return "Kings";
	return string(_v) + "s";
}

function suit_name(_s) {
	switch (_s) {
		case SUIT.HEARTS: return "Hearts";
		case SUIT.SPADES: return "Spades";
		case SUIT.CLUBS: return "Clubs";
	}
	return "Diamonds";
}

function straight_span(_start) {
	var _text = "";
	for (var k = 0; k < 5; k++) {
		var _cv = _start + k;
		if (_cv > 13) _cv -= 13;
		if (_text != "") _text += "-";
		_text += rank_short(_cv);
	}
	return _text;
}

function bet_to_text(_cat, _v1, _v2) {
	switch (_cat) {
		case POKER_HAND.HIGH_CARD: return "High Card " + rank_short(_v1);
		case POKER_HAND.PAIR: return "Pair of " + rank_plural(_v1);
		case POKER_HAND.TWO_PAIR: return "Two Pair, " + rank_plural(_v1) + " and " + rank_plural(_v2);
		case POKER_HAND.THREE_KIND: return "Three " + rank_plural(_v1);
		case POKER_HAND.FLUSH: return "Flush of " + suit_name(_v1);
		case POKER_HAND.STRAIGHT: return "Straight " + straight_span(_v1);
		case POKER_HAND.FULL_HOUSE: return "Full House, " + rank_plural(_v1) + " over " + rank_plural(_v2);
		case POKER_HAND.FOUR_KIND: return "Four " + rank_plural(_v1);
		case POKER_HAND.STRAIGHT_FLUSH: return "Straight Flush " + straight_span(_v1) + " of " + suit_name(_v2);
		case POKER_HAND.ROYAL_FLUSH: return "Royal Flush of " + suit_name(_v1);
	}
	return "Unknown bet";
}

/// Highest "out at" the 52-card deck can still deal: players * (out_at - 1) <= 52.
function max_out_at(_players) {
	if (_players < 1) return 2;
	return floor(52 / _players) + 1;
}

/// Rolling list of the last 6 claims. The oldest drops off when a 7th arrives.
function push_bet_log(_line) {
	var _ctrl = obj_game_controller;
	array_push(_ctrl.bet_log, _line);
	while (array_length(_ctrl.bet_log) > 6) {
		array_delete(_ctrl.bet_log, 0, 1);
	}
}

/// Seats that are not bots. Solo play is one human and the rest bots.
function count_humans() {
	var _ctrl = obj_game_controller;
	var _n = 0;
	for (var i = 0; i < _ctrl.num_players; i++) {
		if (!_ctrl.is_bot[i]) _n++;
	}
	return _n;
}

/// Included files are not always copied into working_directory when you press F5.
/// Search the runtime folder and the project folder.
function music_find(_file_name) {
	var _paths = [
		working_directory + _file_name,
		working_directory + "datafiles\\" + _file_name,
		program_directory + _file_name,
		program_directory + "datafiles\\" + _file_name,
		"D:\\LyingGame\\datafiles\\" + _file_name,
		"D:\\LyingGame\\" + _file_name
	];
	for (var i = 0; i < array_length(_paths); i++) {
		if (file_exists(_paths[i])) return _paths[i];
	}
	return "";
}

/// Starts the menu song once. The file is about 10 minutes. It is restarted when it ends.
function music_boot() {
	if (variable_global_exists("music_ready") && global.music_ready) return;
	global.music_ready = true;
	global.music_on = true;
	global.music_song = -1;
	global.music_voice = -1;
	global.music_icon = -1;
	global.music_status = "NO FILE";
	display_set_gui_size(5000, 3500);

	// GameMaker can only stream OGG. An mp3 stream is silent.
	// The name is relative so the included file inside the game sandbox is used.
	var _song_path = "";
	if (file_exists("lofi_timer.ogg")) _song_path = "lofi_timer.ogg";
	else _song_path = music_find("lofi_timer.ogg");
	var _icon_path = music_find("speaker_icon.png");

	if (_song_path != "") {
		global.music_song = audio_create_stream(_song_path);
		global.music_voice = audio_play_sound(global.music_song, 100, true);
		if (global.music_voice == -1) {
			global.music_status = "PLAY FAILED";
			show_debug_message("Stream was created but did not play: " + _song_path);
		} else {
			audio_sound_gain(global.music_voice, 1, 0);
			global.music_status = "ON";
			show_debug_message("Music playing from: " + _song_path);
		}
	} else {
		global.music_status = "NO FILE";
		show_debug_message("lofi_timer.ogg was not in the game sandbox. Reopen the project so GameMaker copies included files.");
	}
	if (_icon_path != "") {
		global.music_icon = sprite_add(_icon_path, 1, false, false, 0, 0);
	}
}

/// Call every frame. Restarts the track after the 10 minute file ends.
function music_keep_alive() {
	if (!variable_global_exists("music_ready") || !global.music_on) return;
	if (global.music_song == -1 || global.music_voice == -1) return;
	if (audio_is_paused(global.music_voice)) return;
	if (!audio_is_playing(global.music_voice)) {
		global.music_voice = audio_play_sound(global.music_song, 100, false);
		audio_sound_gain(global.music_voice, 1, 0);
	}
}

function music_toggle() {
	if (!variable_global_exists("music_ready")) music_boot();
	global.music_on = !global.music_on;
	if (global.music_voice == -1 || global.music_song == -1) return;

	if (global.music_on) {
		global.music_status = "ON";
		if (audio_is_paused(global.music_voice)) {
			audio_resume_sound(global.music_voice);
		} else if (!audio_is_playing(global.music_voice)) {
			global.music_voice = audio_play_sound(global.music_song, 100, false);
			audio_sound_gain(global.music_voice, 1, 0);
		}
	} else {
		global.music_status = "OFF";
		audio_pause_sound(global.music_voice);
	}
}

function music_draw_speaker(_x1, _y1, _x2, _y2, _label) {
	draw_set_alpha(0.85);
	draw_set_color(make_color_rgb(18, 28, 24));
	draw_rectangle(_x1, _y1, _x2, _y2, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(_x1, _y1, _x2, _y2, true);

	var _box = min((_x2 - _x1) - 36, (_y2 - _y1) - 36);
	if (_label != "") _box = min(_box, (_y2 - _y1) - 100);
	if (global.music_icon != -1) {
		var _scale = _box / max(1, sprite_get_width(global.music_icon));
		draw_sprite_ext(global.music_icon, 0, _x1 + 18, _y1 + 16, _scale, _scale, 0, c_white, 1);
	}

	if (!global.music_on) {
		draw_set_color(c_red);
		draw_line_width(_x1 + 14, _y1 + 14, _x2 - 14, _y2 - 14, 8);
		draw_line_width(_x2 - 14, _y1 + 14, _x1 + 14, _y2 - 14, 8);
	}

	if (_label != "") {
		draw_set_halign(fa_left);
		draw_set_valign(fa_bottom);
		draw_set_color(global.music_on ? c_aqua : c_gray);
		draw_text_transformed(_x1 + 24, _y2 - 12, _label, 2.6, 2.6, 0);
	}
}

function music_draw_buttons() {
	if (!variable_global_exists("music_ready")) return;
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	music_draw_speaker(_gui_w - 200, _gui_h - 200, _gui_w - 40, _gui_h - 40, "");
	if (room == rm_main_menu) {
		var _word = "MUSIC " + global.music_status;
		music_draw_speaker(160, 160, 920, 430, _word);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

/// Returns true when the click was on a music button.
function music_click_buttons() {
	if (!mouse_check_button_pressed(mb_left)) return false;
	if (!variable_global_exists("music_ready")) music_boot();
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _hit = point_in_rectangle(_mx, _my, _gui_w - 200, _gui_h - 200, _gui_w - 40, _gui_h - 40);
	if (room == rm_main_menu && point_in_rectangle(_mx, _my, 160, 160, 920, 430)) _hit = true;
	if (!_hit) return false;
	music_toggle();
	return true;
}

function control_hint(_ctrl) {
	if (_ctrl.game_over) return "R: play again";
	if (_ctrl.reveal_pending) return "SPACE: deal the next round";
	if (_ctrl.state == GAME_STATE.INPUTTING_BET) return "Click the arrows on a claim. ENTER confirms a higher bet.";
	if (_ctrl.state == GAME_STATE.WAITING_FOR_INPUT) return "B: raise      L: call bluff";
	if (_ctrl.state == GAME_STATE.BOT_THINKING) return "A bot is deciding...";
	if (_ctrl.state == GAME_STATE.SWITCHING_TURN) {
		if (_ctrl.is_bot[_ctrl.current_turn]) return "Next up is a bot.";
		return "SPACE: look at your cards";
	}
	return "";
}
