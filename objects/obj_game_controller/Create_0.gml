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

// Alarm 0 still calls this. The decision itself lives in scr_bot_ai.
execute_bot_turn = function() {
	bot_take_turn();
}

randomize(); //random seed

// Match setup writes these globals. Starting Room1 directly still has a full table.
num_players = variable_global_exists("match_players") ? global.match_players : 4;
lose_condition = variable_global_exists("match_out_at") ? global.match_out_at : 7;
num_bots = variable_global_exists("match_bots") ? global.match_bots : -1;
if (num_players < 2) num_players = 2;
if (num_players > 7) num_players = 7;
if (lose_condition < 2) lose_condition = 2;
if (lose_condition > max_out_at(num_players)) lose_condition = max_out_at(num_players);
if (num_bots < 0) num_bots = num_players - 1;
if (num_bots > num_players - 1) num_bots = num_players - 1;

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
// Seat 1 is always you. Bots fill the last seats. Empty seats before them pass the keyboard.
is_bot = [];
alive = [];
bot_personality = [];
var _first_bot = num_players - num_bots;
for (var i = 0; i < num_players; i++) {
    array_push(is_bot, i >= _first_bot);
	array_push(alive, true);
	array_push(bot_personality, bot_make_personality());
}
reveal_pending = false;
reveal_lines = [];
reveal_header = "";
winner_index = -1;
bet_log = [];
saved_alarm = -1;
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

show_debug_message("Game Initialized for " + string(num_players) + " players. Out at " + string(lose_condition) + " cards.");
show_debug_message("Player 1 starts with: " + hands[0][0].get_name());


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
if (!instance_exists(obj_hud)) {
	instance_create_layer(0, 0, "Instances", obj_hud);
}
display_set_gui_size(5000, 3500);
event_log = "Game Started. Player 1's turn.";