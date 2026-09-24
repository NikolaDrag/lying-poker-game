if (!mouse_check_button_pressed(mb_left)) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _small = [ _gui_w - 200, _gui_h - 200, _gui_w - 40, _gui_h - 40 ];

if (point_in_rectangle(_mx, _my, _small[0], _small[1], _small[2], _small[3])) {
	toggle_music();
} else if (room == rm_main_menu && point_in_rectangle(_mx, _my, menu_hit[0], menu_hit[1], menu_hit[2], menu_hit[3])) {
	toggle_music();
}
