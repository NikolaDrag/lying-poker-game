// Global definitions

enum SUIT {
    DIAMONDS,   // This is 0
    HEARTS, // This is 1
	SPADES,	  // This is 2
    CLUBS     // This is 3
       
}

enum POKER_HAND {
    HIGH_CARD,   // Becomes 0
    PAIR,        // Becomes 1
    TWO_PAIR,    // Becomes 2
    THREE_KIND, //3
	FLUSH,// 4
    STRAIGHT,	//5 
    FULL_HOUSE, //6
    FOUR_KIND, // 7
    STRAIGHT_FLUSH, // 8
    ROYAL_FLUSH     // 9
}

enum GAME_STATE {
    WAITING_FOR_INPUT, // Human turn - waiting for keypresses
    INPUTTING_BET,     // Human turn - UI is open
    SWITCHING_TURN,    // The "Pass Keyboard" screen
    BOT_THINKING,      // AI turn - waiting for Alarm 0
    GAME_OVER
}

// Constructor Blueprint
function Card(_suit, _value) constructor {
    suit = _suit;
    value = _value;
    
    // You can even add "methods" like C++ member functions
    static get_name = function() {
	    var _s_name = "";
	    switch(suit) {
	        case SUIT.HEARTS:   _s_name = "Hearts"; break;
	        case SUIT.DIAMONDS: _s_name = "Diamonds"; break;
	        case SUIT.CLUBS:    _s_name = "Clubs"; break;
	        case SUIT.SPADES:   _s_name = "Spades"; break;
	    }
    
	    var _v_name = string(value);
	    if (value == 1)  _v_name = "Ace";
	    if (value == 11) _v_name = "Jack";
	    if (value == 12) _v_name = "Queen";
	    if (value == 13) _v_name = "King";
    
	    return _v_name + " of " + _s_name;
	}
}

function Bet(_cat, _v1, _v2, _player) constructor {
    category = _cat;
    value1 = _v1;
    value2 = _v2;
    better_index = _player;
}



