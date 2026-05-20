confirm_bet = function() {
    if (obj_game_controller.is_bet_valid_increase(temp_cat, temp_v1, temp_v2)) {
        obj_game_controller.current_bet = new Bet(temp_cat, temp_v1, temp_v2, obj_game_controller.current_turn);
        
        // Use the global function to switch players
        next_turn(); 
        
        instance_destroy(); // Close the betting menu
    } else {
        // Optional: Add a screen shake or "Invalid" sound here
        show_debug_message("Invalid Bet Hierarchy!");
    }
}
image_speed = 0;//zashto bez tova value 2 cikleshe no category i value 1 ne????
// Make the GUI layer match our high-res assets
display_set_gui_size(5000, 3500); 

// Initial temp values (start at current bet)
var _cb = obj_game_controller.current_bet;
temp_cat = _cb.category;
temp_v1 = _cb.value1;
if (temp_cat != POKER_HAND.FLUSH && temp_v1 == 0) temp_v1 = 1;
temp_v2 = _cb.value2;

ui_y = 3200;
ui_x = [2500, 3600, 4350]; // Spread them out across the 5000 width, mejdu val1 val 2 da e 750
//