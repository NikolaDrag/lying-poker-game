/// One persistent player for the menu and the match.
/// The file is about 10 minutes long. loop=true restarts it when it ends,
/// so a long game does not go quiet at the 10 minute mark.
persistent = true;
depth = -16000;
display_set_gui_size(5000, 3500);

music_on = true;
song = -1;
voice = -1;
icon = -1;

var _song_path = working_directory + "lofi_timer.mp3";
var _icon_path = working_directory + "speaker_icon.png";

if (file_exists(_song_path)) {
	song = audio_create_stream(_song_path);
	voice = audio_play_sound(song, 10, true);
} else {
	show_debug_message("Music file was not found: " + _song_path);
}

if (file_exists(_icon_path)) {
	icon = sprite_add(_icon_path, 1, false, false, 0, 0);
}

// Main-menu control, room coordinates in the 5000x3500 GUI.
menu_hit = [160, 160, 920, 430];

draw_speaker_button = function(_x1, _y1, _x2, _y2, _label) {
	draw_set_alpha(0.85);
	draw_set_color(make_color_rgb(18, 28, 24));
	draw_rectangle(_x1, _y1, _x2, _y2, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(_x1, _y1, _x2, _y2, true);

	var _pad = 18;
	var _box = min((_x2 - _x1) - 36, (_y2 - _y1) - 36);
	if (_label != "") _box = min(_box, (_y2 - _y1) - 100);
	var _ix = _x1 + _pad;
	var _iy = _y1 + _pad;

	if (icon != -1) {
		var _spr_w = max(1, sprite_get_width(icon));
		var _scale = _box / _spr_w;
		draw_sprite_ext(icon, 0, _ix, _iy, _scale, _scale, 0, c_white, 1);
	}

	if (!music_on) {
		draw_set_color(c_red);
		draw_line_width(_x1 + 14, _y1 + 14, _x2 - 14, _y2 - 14, 8);
		draw_line_width(_x2 - 14, _y1 + 14, _x1 + 14, _y2 - 14, 8);
	}

	if (_label != "") {
		draw_set_halign(fa_left);
		draw_set_valign(fa_bottom);
		draw_set_color(music_on ? c_aqua : c_gray);
		draw_text_transformed(_x1 + 24, _y2 - 12, _label, 2.6, 2.6, 0);
	}
};

toggle_music = function() {
	music_on = !music_on;
	if (voice == -1 || song == -1) return;

	if (music_on) {
		if (audio_is_paused(voice)) {
			audio_resume_sound(voice);
		} else if (!audio_is_playing(voice)) {
			voice = audio_play_sound(song, 10, true);
		}
	} else {
		audio_pause_sound(voice);
	}
};
