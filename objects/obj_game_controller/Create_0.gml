refresh_hand_visuals = function(_target_p_idx) {
    // 1. Clear the old cards from the screen
	with (obj_card) {
		instance_destroy();
	 }
	if(!is_bot[current_turn]){
	    // 2. Point to the specific player's data
	    var _hand_data = hands[_target_p_idx]; 
    
	    var _start_x = 320;
	    var _y_pos = 2830 - 800; 
	    var _spacing = 240;
	    var _base_depth = layer_get_depth("Instances");

	    // 3. Spawn the objects for THAT specific player
	    for (var i = 0; i < array_length(_hand_data); i++) {
	        var _inst = instance_create_depth(_start_x + (i * _spacing), _y_pos, _base_depth - i, obj_card);
	        _inst.card_data = _hand_data[i];
	    }
	}
}// napravi rukata nanovo s novata karta

reset_round = function() {
    // 1. Record current hand counts (P1 has 4, P2 has 2, etc.)
    var _counts = [];
    for (var i = 0; i < num_players; i++) {
        array_push(_counts, array_length(hands[i]));
    }

    // 2. Nuke everything
    hands = [];
    deck = [];
    with(obj_card) instance_destroy();
    with(obj_betting_ui) instance_destroy();
    msg_cat = -1;
    msg_val1 = -1;
    msg_val2 = -1;

    // 3. Build a fresh 52-card deck
    for (var i = 1; i <= 13; i++) {
        for (var s = 0; s < 4; s++) {
            array_push(deck, new Card(s, i));
        }
    }
    array_shuffle_ext(deck);

    // 4. Deal fresh cards back to players
    for (var p = 0; p < num_players; p++) {
        var _new_hand = [];
        repeat(_counts[p]) {
            array_push(_new_hand, array_pop(deck));
        }
        array_push(hands, _new_hand);
    }

    current_bet = new Bet(POKER_HAND.HIGH_CARD, 0, 0, -1);
    
    // We don't call refresh_hand_visuals here because 
    // the Spacebar check in the Step event will call it 
    // when the next player actually takes the keyboard.
}

/// @desc Checks if the new bet is higher than the current one.
is_bet_valid_increase = function(_new_cat, _new_v1, _new_v2) {
    var _curr = current_bet;
    
    // Helper to treat Ace (1) as 14
    var _get_power = function(_v) { return (_v == 1) ? 14 : _v; };// value remapper
    // Straights treat A-2-3-4-5 as the lowest sequence
    var _get_straight_power = function(_v) { return (_v == 1) ? 1 : _v; };

    // --- CASE 1: Higher Category (e.g., Flush beats Straight) ---
    if (_new_cat > _curr.category) return true;
    
    // --- CASE 2: Same Category (e.g., Three of a Kind vs Three of a Kind) ---
    if (_new_cat == _curr.category) {
        if (_new_cat == POKER_HAND.STRAIGHT || _new_cat == POKER_HAND.STRAIGHT_FLUSH) {
            var _new_p1 = _get_straight_power(_new_v1);
            var _curr_p1 = _get_straight_power(_curr.value1);
            
            if (_new_p1 > _curr_p1) return true;
            
            if (_new_p1 == _curr_p1 && _new_cat == POKER_HAND.STRAIGHT_FLUSH) {
                var _new_p2 = _new_v2;
                var _curr_p2 = _curr.value2;
                if (_new_p2 > _curr_p2) return true;
            }
            return false;
        }

        if (_new_cat == POKER_HAND.FLUSH) {
            if (_new_v1 > _curr.value1) return true;
            return false;
        }
        
        var _new_p1 = _get_power(_new_v1);
        var _curr_p1 = _get_power(_curr.value1);
        
        // 2a. Primary value is stronger (e.g., 3 Aces beats 3 Kings)
        if (_new_p1 > _curr_p1) return true;
        
        // 2b. Primary is equal, check secondary (Two Pair or Full House)
        if (_new_p1 == _curr_p1) {
            if (_new_cat == POKER_HAND.TWO_PAIR || _new_cat == POKER_HAND.FULL_HOUSE) { //moje bi izlishno no e safeguard
                var _new_p2 = _get_power(_new_v2);
                var _curr_p2 = _get_power(_curr.value2);
            
                if (_new_p2 > _curr_p2) return true;
            }
        }
    }
    
    return false; // Lower or identical bet
}

execute_bot_turn = function() {
    var _cb = current_bet;
    var _my_hand = hands[current_turn];
    var _hand_len = array_length(_my_hand);
    
    // Count total cards in game
    var _total_cards = 0;
    for(var i=0; i<num_players; i++) _total_cards += array_length(hands[i]);

    // --- 1. ANALYZE MY OWN HAND ---
    // Find my most frequent card value to use as a "Strong Point"
    var _val_counts = array_create(14, 0);
    var _best_val = irandom_range(2, 13); // Default to random if hand is empty
    var _max_seen = 0;
    
    for (var i = 0; i < _hand_len; i++) {
        var _v = _my_hand[i].value;
        _val_counts[_v]++;
        if (_val_counts[_v] > _max_seen) {
            _max_seen = _val_counts[_v];
            _best_val = _v;
        }
    }

    // --- 2. EVALUATE PREVIOUS BET ---
    var _i_have = _val_counts[_cb.value1];
    
    // Probability estimation: 
    // "I have X, and there are Y cards I can't see. Roughly 1 out of 13 cards should match."
    var _others_likely_have = (_total_cards - _hand_len) / 10; // Aggressive estimate
    var _estimated_total = _i_have + _others_likely_have;
    
    // Confidence is how much the current bet exceeds our estimation
    // Higher threshold = Bot is more "Trusting"
    var _needed_for_bet = 1; // Default for High Card
    if (_cb.category == POKER_HAND.PAIR) _needed_for_bet = 2;
    if (_cb.category == POKER_HAND.THREE_KIND) _needed_for_bet = 3;
    
    var _confidence = (_estimated_total / _needed_for_bet) * random_range(0.8, 1.4);

    // --- 3. DECIDE: CHALLENGE OR RAISE ---
    // If confidence is very low, and it's not a fresh round, call Liar
    if (_cb.better_index != -1 && _confidence < 0.6) {
        event_log = "P" + string(current_turn + 1) + " thinks P" + string(_cb.better_index + 1) + " is bluffing!";
        call_liar(current_turn);
    } 
    else {
        // --- 4. RAISE LOGIC (The "Gnome Jump") ---
        var _new_cat = _cb.category;
        var _new_v1 = _cb.value1;
        
        // If starting fresh, start with something I actually have!
        if (_cb.better_index == -1) {
            _new_v1 = _best_val;
            _new_cat = (_max_seen >= 2) ? POKER_HAND.PAIR : POKER_HAND.HIGH_CARD;
        } 
        else {
            // Decide how much to jump (1 to 3 values)
            var _jump = irandom_range(1, 3);
            
            // If I have the card, I'm more likely to jump higher
            if (_val_counts[_cb.value1] > 0) _jump = irandom_range(2, 4);

            // Apply jump with power-remap (Ace is 14)
            repeat(_jump) {
                if (_new_v1 == 1) { // Current is Ace
                    _new_v1 = 2;
                    _new_cat++;
                } else if (_new_v1 == 13) { // Current is King
                    _new_v1 = 1; // Move to Ace
                } else {
                    _new_v1++;
                }
            }
        }

        // Final Safety
        if (_new_cat > 9) _new_cat = 9;
        
        current_bet = new Bet(_new_cat, _new_v1, 0, current_turn);
        
        // Make the log sound natural
        var _val_name = (_new_v1 == 1) ? "Aces" : string(_new_v1) + "s";
        event_log = "P" + string(current_turn + 1) + " raises: " + hand_names[_new_cat] + " of " + _val_name;
        
        next_turn();
    }
}

randomize(); //random seed

num_players = 4; 
lose_condition = 5; // Reach 7 cards to lose
current_turn = 0;
state = GAME_STATE.WAITING_FOR_INPUT;
// In Create Event
hand_names = ["High Card", "Pair", "Two Pair", "3 of a Kind", "Flush", "Straight", "Full House", "4 of a Kind", "Str. Flush", "Royal Flush"];
// Initialize temp variables for async input
msg_cat = -1;
msg_val1 = -1;
msg_val2 = -1;
temp_cat = 0;
temp_val1 = 0;
temp_val2 = 0;
// 0 = Human, 1+ = Bots
is_bot = [];
for (var i = 0; i < num_players; i++) {
    array_push(is_bot, i != 0);
}
// Create the Deck, naredeni dvoiki
deck = [];
current_bet = new Bet(POKER_HAND.HIGH_CARD, 0, 0, -1);//category, value 1, value 2 , playerindex
for (var i = 1; i <= 13; i++) {
    for (var s = 0; s < 4; s++) {
        // We create a "struct"
        var _new_card = new Card(s, i); // no delete needed we have garbage collector
        array_push(deck,_new_card);
    }
}
array_shuffle_ext(deck); // Shuffle deck

// hands[0] is Player 1, hands[1] is Player 2, etc.
hands = []; 

for (var p = 0; p < num_players; p++) {// Deal 1 card - starting deal
    var starting_hand = [];
    
    array_push(starting_hand, array_pop(deck));
    
    array_push(hands, starting_hand);
}

current_turn = 0; // Player 0 starts
game_over = false;

var _p1_card = hands[0][0];
var _p1_card2 = hands[0][1];
var _p1_card3 = hands[0][2];
var _p2_card = hands[1][0];
//var _p3_card = hands[2][0];
//var _p4_card = hands[3][0];

show_debug_message("Game Initialized for " + string(num_players) + " players.");
show_debug_message("Player 1 starts with: " + _p1_card.get_name());
show_debug_message("Player 1.2 starts with: " + _p1_card2.get_name());
show_debug_message("Player 1.3 starts with: " + _p1_card3.get_name());
//show_debug_message("Player 4 starts with: " + _p4_card.get_name());


// 1. Coordinates for the player's hand
var _start_x = 320; //0,0 e gore vlqvo
var _y_pos = 2830 -800; 
var _spacing = 240; // Adjust this based on your card width

var _p1_hand = hands[0]; 

// Get the base depth of your layer so we stay in the right visual "neighborhood"
var _base_depth = layer_get_depth("Instances");

for (var i = 0; i < array_length(_p1_hand); i++) {
    // Use instance_create_depth instead of layer - nezavisim ot layerite
    // We SUBTRACT i so that as i increases, the depth gets SMALLER (closer to screen)
    var _target_depth = _base_depth - i; 
    
    var _inst = instance_create_depth(_start_x + (i * _spacing), _y_pos, _target_depth, obj_card);
    
    _inst.card_data = _p1_hand[i];
}
show_debug_message("Instance Count: " + string(instance_number(obj_card)));

if (!instance_exists(obj_opponents)) {
    instance_create_layer(0, 0, "Opponent_Layer", obj_opponents);// call object opponents constructor
}
display_set_gui_size(5000, 3500);
event_log = "Game Started. Player 1's turn.";