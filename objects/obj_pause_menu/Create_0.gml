/// Pause overlay. The first Escape that opened this menu is ignored
/// so the same keypress does not immediately close it.
ignore_escape = true;
can_leave = (count_humans() <= 1);
display_set_gui_size(5000, 3500);

hit_resume = [1700, 1500, 3300, 1760];
hit_menu = [1700, 1880, 3300, 2140];

resume_match = function() {
	if (instance_exists(obj_game_controller) && obj_game_controller.saved_alarm > 0) {
		obj_game_controller.alarm[0] = obj_game_controller.saved_alarm;
	}
	instance_destroy();
};
