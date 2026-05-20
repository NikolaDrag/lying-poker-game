/// @desc Checks if the current collective pool satisfies the bet.
/// @param {real} category The POKER_HAND enum index.
/// @param {real} value1 The primary card value (1-13).
/// @param {real} value2 The secondary value (for pairs/full house).
/// @returns {bool}
function check_bet(category, value1, value2) { //value 1 would be the suit for suit based calls like flush
	var _hands = obj_game_controller.hands;
	var _counts = array_create(14, 0); //ot vsqka cifra kolko
	var _suit_counts = array_create(4, 0);// ot vseki suit kolko
    
	// 2D Matrix: matrix[suit][value] = count
	var _matrix = array_create(4); //ot vseki suit kolko ima?, 
	//if we used only the matrix it would be inefficient for non straiht flush checks
	for (var i = 0; i < 4; i++) _matrix[i] = array_create(14, 0);

	// 1. Fill our data structures
	for (var i = 0; i < array_length(_hands); i++) { //za vsqka ruka
	    var _h = _hands[i];
	    for (var j = 0; j < array_length(_h); j++) { //za vsqka karta v rukata
	        var _c = _h[j];
	        _counts[_c.value]++;
	        _suit_counts[_c.suit]++;
	        _matrix[_c.suit][_c.value]++;
	    }
	}
    // 3. Switch based on category (Pair, 3 of a Kind, etc.)
    // Return true if the counts satisfy the bet, false if not.
    switch (category) {
        case POKER_HAND.HIGH_CARD:
            // Does at least one card of this value exist?
            return (_counts[value1] >= 1);

        case POKER_HAND.PAIR:
            return (_counts[value1] >= 2);

        case POKER_HAND.TWO_PAIR:
            if (value1 == value2) return false; 
			return (_counts[value1] >= 2 && _counts[value2] >= 2);

        case POKER_HAND.THREE_KIND:
            return (_counts[value1] >= 3);

        case POKER_HAND.STRAIGHT:
		    // 1. Max straight starts at 10 (10, J, Q, K, A)
		    if (value1 > 10) return false; 
    
		    for (var k = 0; k < 5; k++) {
			    // Start at value1, add k, then wrap back to 1 if we pass 13
			    var _cv = value1 + k;
			    if (_cv > 13) _cv -= 13; // Subtracts 13 to correctly wrap 14 to 1, 15 to 2, etc.
    
			    if (_counts[_cv] < 1) return false;
			}
		    return true; // If the loop finished, the truth is out there!

        case POKER_HAND.FULL_HOUSE:
            if (value1 == value2) return false;
			return (_counts[value1] >= 3 && _counts[value2] >= 2);

        case POKER_HAND.FOUR_KIND:
            return (_counts[value1] >= 4);

        case POKER_HAND.FLUSH:
            // In Liar's Poker, Flush usually means 5 cards of the same SUIT.
            // Since your _counts only tracks values, we need a suit check:
            return (_suit_counts[value1] >= 5); // value1 would be the suit index (0-3)
			
		case POKER_HAND.STRAIGHT_FLUSH:
            // value1 is the start of the straight, value2 is the SUIT (0-3)
            if (value1 > 10) return false;
            
            for (var k = 0; k < 5; k++) {
                var _cv = value1 + k;
                if (_cv > 13) _cv = 1; // Ace wrap-around
                
                // Check matrix at [suit][value]
                if (_matrix[value2][_cv] < 1) return false;
            }
            return true;

        case POKER_HAND.ROYAL_FLUSH:
		    var _s = value1; // Here value1 is the suit
		    return (_matrix[_s][10] >= 1 && 
		            _matrix[_s][11] >= 1 && 
		            _matrix[_s][12] >= 1 && 
		            _matrix[_s][13] >= 1 && 
		            _matrix[_s][1]  >= 1);
    }
}

function next_turn() {
    var _ctrl = obj_game_controller; //pointer to the object, unique integer ID of the object
    
    _ctrl.current_turn++;
    if (_ctrl.current_turn >= _ctrl.num_players) _ctrl.current_turn = 0;
    _ctrl.state = GAME_STATE.SWITCHING_TURN;
	with (obj_card) {
        instance_destroy();
    }
    // Good for C++ style debugging
    show_debug_message("Turn switched to Player: " + string(_ctrl.current_turn + 1));
}

function call_liar(_caller_idx) {
    var _ctrl = obj_game_controller;
    var _bet = _ctrl.current_bet; 

    if (_bet.better_index == -1) {
        show_debug_message("Wait! No bets have been placed yet.");
        return;
    }

    // 2. The Verification
    // Assuming check_bet counts the actual cards on the table
    var _is_bet_valid = check_bet(_bet.category, _bet.value1, _bet.value2);
    var _loser_idx = _is_bet_valid ? _caller_idx : _bet.better_index;

    // Build the Log Message
    var _msg = "P" + string(_caller_idx + 1) + " called LIAR! ";
    if (_is_bet_valid) {
        _msg += "The bet was TRUE. P" + string(_caller_idx + 1) + " draws.";
    } else {
        _msg += "P" + string(_bet.better_index + 1) + " was BLUFFING and draws.";
    }
    _ctrl.event_log = _msg; 

    // 3. The Penalty
    if (array_length(_ctrl.deck) > 0) {
        var _new_card = array_pop(_ctrl.deck);
        array_push(_ctrl.hands[_loser_idx], _new_card);
    }

    // 4. Game Over or Round Reset
    if (array_length(_ctrl.hands[_loser_idx]) >= _ctrl.lose_condition) {
        _ctrl.game_over = true;
        _ctrl.refresh_hand_visuals(_loser_idx);
    } else {
        // --- CRITICAL SCOPE FIXES ---
        _ctrl.current_turn = _loser_idx; // Loser starts
        _ctrl.reset_round();             // Added _ctrl prefix
        _ctrl.state = GAME_STATE.SWITCHING_TURN; // Added _ctrl prefix
    }

    // 5. Reset Round State
    _ctrl.current_bet = new Bet(POKER_HAND.HIGH_CARD, 0, 0, -1);
}