var _id = async_load[? "id"];
var _status = async_load[? "status"];
var _value = async_load[? "value"];

if (_status) { 
    // --- CATEGORY INPUT ---
    if (_id == msg_cat) {
        // Validation: Category must be 0-9 (or however many enums you have)
        if (_value < 0 || _value > 9) {
            msg_cat = get_integer_async("INVALID CATEGORY! Enter 0-9:", 0);
            exit;
        }
        temp_cat = _value;
        var _prompt = "Value 1 (1-13):";
        if (temp_cat == POKER_HAND.FLUSH) {
            _prompt = "Suit (0:D, 1:H, 2:S, 3:C):";
        } else if (temp_cat == POKER_HAND.STRAIGHT || temp_cat == POKER_HAND.STRAIGHT_FLUSH) {
            _prompt = "Straight start (1-10):";
        }
        msg_val1 = get_integer_async(_prompt, 1);
    }
    
    // --- VALUE 1 INPUT ---
    else if (_id == msg_val1) {
        if (temp_cat == POKER_HAND.FLUSH) {
            if (_value < 0 || _value > 3) {
                msg_val1 = get_integer_async("INVALID SUIT! Enter 0-3:", 0);
                exit;
            }
        } else if (temp_cat == POKER_HAND.STRAIGHT || temp_cat == POKER_HAND.STRAIGHT_FLUSH) {
            if (_value < 1 || _value > 10) {
                msg_val1 = get_integer_async("INVALID START! Enter 1-10:", 1);
                exit;
            }
        } else if (_value < 1 || _value > 13) {
            msg_val1 = get_integer_async("INVALID VALUE! Enter 1-13:", 1);
            exit;
        }

        temp_val1 = _value;
        var _prompt2 = "Value 2 (or 0 if not needed):";
        if (temp_cat == POKER_HAND.TWO_PAIR || temp_cat == POKER_HAND.FULL_HOUSE) {
            _prompt2 = "Value 2 (1-13):";
        } else if (temp_cat == POKER_HAND.STRAIGHT_FLUSH) {
            _prompt2 = "Suit (0:D, 1:H, 2:S, 3:C):";
        }
        msg_val2 = get_integer_async(_prompt2, 0);
    }
    
    // --- VALUE 2 INPUT (FINALIZATION) ---
    else if (_id == msg_val2) {
        if (temp_cat == POKER_HAND.STRAIGHT_FLUSH) {
            if (_value < 0 || _value > 3) {
                msg_val2 = get_integer_async("INVALID SUIT! Enter 0-3:", 0);
                exit;
            }
        } else if (temp_cat == POKER_HAND.TWO_PAIR || temp_cat == POKER_HAND.FULL_HOUSE) {
            if (_value < 1 || _value > 13 || _value == temp_val1) {
                msg_val2 = get_integer_async("VALUES MUST BE 1-13 AND DIFFERENT! Value 2:", 1);
                exit;
            }
        } else if (_value != 0) {
            msg_val2 = get_integer_async("Value 2 must be 0:", 0);
            exit;
        }

        temp_val2 = _value;
        
        // --- BET HIERARCHY CHECK ---
        if (is_bet_valid_increase(temp_cat, temp_val1, temp_val2)) {
            // Success! Update global state
            current_bet = new Bet(temp_cat, temp_val1, temp_val2, current_turn);
            event_log = "P" + string(current_turn + 1) + " bet Cat " + string(temp_cat);
            
            // Move to next player's switch screen
            next_turn(); 
        } else {
            // Failure! Tell them why and let them try again
            show_message_async("Invalid bet! You must bet higher than P" + string(current_bet.better_index + 1) + "'s bet.");
            state = GAME_STATE.WAITING_FOR_INPUT; 
        }
    }
} else {
    // User hit 'Cancel' - return to wait state
    state = GAME_STATE.WAITING_FOR_INPUT; 
}