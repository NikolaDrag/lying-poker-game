if (ignore_escape) {
	ignore_escape = false;
} else if (keyboard_check_pressed(vk_escape)) {
	resume_match();
	exit;
}

if (!mouse_check_button_pressed(mb_left)) exit;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

if (point_in_rectangle(_mx, _my, hit_resume[0], hit_resume[1], hit_resume[2], hit_resume[3])) {
	resume_match();
} else if (can_leave && point_in_rectangle(_mx, _my, hit_menu[0], hit_menu[1], hit_menu[2], hit_menu[3])) {
	room_goto(rm_main_menu);
}
