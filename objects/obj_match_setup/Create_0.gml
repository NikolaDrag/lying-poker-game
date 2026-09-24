/// New Game settings. Options and Quit stay on the menu behind this panel.
players = variable_global_exists("match_players") ? global.match_players : 4;
out_at = variable_global_exists("match_out_at") ? global.match_out_at : 7;
bots = variable_global_exists("match_bots") ? global.match_bots : 3;
players = clamp(players, 2, 7);
out_at = clamp(out_at, 2, max_out_at(players));
bots = clamp(bots, 0, players - 1);

display_set_gui_size(5000, 3500);

// [x1, y1, x2, y2] in GUI space, which matches the 5000x3500 room.
// Up sits above the number, down sits below it.
hit_players_up = [1480, 1080, 1920, 1360];
hit_players_down = [1480, 1580, 1920, 1860];
hit_bots_up = [2280, 1080, 2720, 1360];
hit_bots_down = [2280, 1580, 2720, 1860];
hit_out_up = [3080, 1080, 3520, 1360];
hit_out_down = [3080, 1580, 3520, 1860];
hit_start = [1550, 2360, 3450, 2600];
hit_back = [1900, 2700, 3100, 2920];
