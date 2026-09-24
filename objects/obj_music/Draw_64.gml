/// Speaker icon. A red cross means the song is paused.

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
draw_speaker_button(_gui_w - 200, _gui_h - 200, _gui_w - 40, _gui_h - 40, "");

if (room == rm_main_menu) {
	var _word = music_on ? "MUSIC ON" : "MUSIC OFF";
	draw_speaker_button(menu_hit[0], menu_hit[1], menu_hit[2], menu_hit[3], _word);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
