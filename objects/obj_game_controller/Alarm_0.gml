execute_bot_turn();
if (state == GAME_STATE.WAITING_FOR_INPUT && is_bot[current_turn]) {
    next_turn();
}