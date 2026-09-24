// Escape opens the pause menu. While it is open, the turn loop waits.
if (instance_exists(obj_pause_menu)) exit;
if (keyboard_check_pressed(vk_escape)) {
    saved_alarm = alarm[0];
    alarm[0] = -1;
    instance_create_layer(0, 0, "UI_Layer", obj_pause_menu);
    exit;
}

if (game_over) {
    if (keyboard_check_pressed(ord("R"))) room_restart();
    exit; 
}

switch (state) {
    case GAME_STATE.SWITCHING_TURN:
        // Reveal stays up until the player at the keyboard presses Space.
        // That same press then falls through into the normal pass / bot delay.
        if (reveal_pending) {
            if (keyboard_check_pressed(vk_space)) {
                reveal_pending = false;
                reveal_lines = [];
                reveal_header = "";
                reset_round();
            } else {
                break;
            }
        }

        // If it's a bot's turn, don't make the human press Space
        if (is_bot[current_turn]) {
            with (obj_card) instance_destroy(); // Clear screen
            state = GAME_STATE.BOT_THINKING;
            alarm[0] = room_speed * random_range(3, 8); // Each bot waits a different 3 to 8 seconds
        } 
        else {
            // Human turn: Wait for Spacebar
            if (keyboard_check_pressed(vk_space)) {
                with (obj_card) instance_destroy();
                refresh_hand_visuals(current_turn);
                state = GAME_STATE.WAITING_FOR_INPUT;
            }
        }
        break;

    case GAME_STATE.WAITING_FOR_INPUT:
        // This case now only runs for HUMANS because bots skip to BOT_THINKING
        if (keyboard_check_pressed(ord("B"))) {
            state = GAME_STATE.INPUTTING_BET;
            instance_create_layer(0, 0, "UI_Layer", obj_betting_ui);
        }
        
        if (keyboard_check_pressed(ord("L"))) {
            call_liar(current_turn); // Or resolve_challenge();
        }
        break;
        
    case GAME_STATE.BOT_THINKING:
        // We are just waiting for Alarm 0 to trigger execute_bot_turn()
        // No input allowed here!
        break;

    case GAME_STATE.INPUTTING_BET:
        // Waiting for the Betting UI to call instance_destroy()
        break;
}