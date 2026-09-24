draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

draw_set_color(make_color_rgb(18, 28, 24));
draw_rectangle(1400, 900, 3600, 2400, false);
draw_set_color(c_white);
draw_rectangle(1400, 900, 3600, 2400, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_yellow);
draw_text_transformed(2500, 1100, "PAUSED", 6, 6, 0);

draw_set_color(c_ltgray);
if (can_leave) {
	draw_text_transformed(2500, 1320, "You are the only human. You can leave the match.", 2.8, 2.8, 0);
} else {
	draw_text_transformed(2500, 1320, "Other humans are still at the table.", 2.8, 2.8, 0);
}

draw_set_color(c_green);
draw_rectangle(hit_resume[0], hit_resume[1], hit_resume[2], hit_resume[3], false);
draw_set_color(c_white);
draw_text_transformed(2500, (hit_resume[1] + hit_resume[3]) * 0.5, "RESUME", 4.5, 4.5, 0);

if (can_leave) {
	draw_set_color(c_maroon);
	draw_rectangle(hit_menu[0], hit_menu[1], hit_menu[2], hit_menu[3], false);
	draw_set_color(c_white);
	draw_text_transformed(2500, (hit_menu[1] + hit_menu[3]) * 0.5, "MAIN MENU", 4.5, 4.5, 0);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
