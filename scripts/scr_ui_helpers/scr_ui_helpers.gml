/// Human-readable names for seats, claims, and the on-screen control hint.
/// The betting arrows and the poker enum order are not defined here.

function seat_name(_idx) {
	if (_idx == 0) return "You";
	return "P" + string(_idx + 1);
}

function rank_short(_v) {
	if (_v == 1) return "A";
	if (_v == 11) return "J";
	if (_v == 12) return "Q";
	if (_v == 13) return "K";
	return string(_v);
}

function rank_plural(_v) {
	if (_v == 1) return "Aces";
	if (_v == 11) return "Jacks";
	if (_v == 12) return "Queens";
	if (_v == 13) return "Kings";
	return string(_v) + "s";
}

function suit_name(_s) {
	switch (_s) {
		case SUIT.HEARTS: return "Hearts";
		case SUIT.SPADES: return "Spades";
		case SUIT.CLUBS: return "Clubs";
	}
	return "Diamonds";
}

function straight_span(_start) {
	var _text = "";
	for (var k = 0; k < 5; k++) {
		var _cv = _start + k;
		if (_cv > 13) _cv -= 13;
		if (_text != "") _text += "-";
		_text += rank_short(_cv);
	}
	return _text;
}

function bet_to_text(_cat, _v1, _v2) {
	switch (_cat) {
		case POKER_HAND.HIGH_CARD: return "High Card " + rank_short(_v1);
		case POKER_HAND.PAIR: return "Pair of " + rank_plural(_v1);
		case POKER_HAND.TWO_PAIR: return "Two Pair, " + rank_plural(_v1) + " and " + rank_plural(_v2);
		case POKER_HAND.THREE_KIND: return "Three " + rank_plural(_v1);
		case POKER_HAND.FLUSH: return "Flush of " + suit_name(_v1);
		case POKER_HAND.STRAIGHT: return "Straight " + straight_span(_v1);
		case POKER_HAND.FULL_HOUSE: return "Full House, " + rank_plural(_v1) + " over " + rank_plural(_v2);
		case POKER_HAND.FOUR_KIND: return "Four " + rank_plural(_v1);
		case POKER_HAND.STRAIGHT_FLUSH: return "Straight Flush " + straight_span(_v1) + " of " + suit_name(_v2);
		case POKER_HAND.ROYAL_FLUSH: return "Royal Flush of " + suit_name(_v1);
	}
	return "Unknown bet";
}

/// Highest "out at" the 52-card deck can still deal: players * (out_at - 1) <= 52.
function max_out_at(_players) {
	if (_players < 1) return 2;
	return floor(52 / _players) + 1;
}

/// Rolling list of the last 6 claims. The oldest drops off when a 7th arrives.
function push_bet_log(_line) {
	var _ctrl = obj_game_controller;
	array_push(_ctrl.bet_log, _line);
	while (array_length(_ctrl.bet_log) > 6) {
		array_delete(_ctrl.bet_log, 0, 1);
	}
}

/// Seats that are not bots. Solo play is one human and the rest bots.
function count_humans() {
	var _ctrl = obj_game_controller;
	var _n = 0;
	for (var i = 0; i < _ctrl.num_players; i++) {
		if (!_ctrl.is_bot[i]) _n++;
	}
	return _n;
}

function control_hint(_ctrl) {
	if (_ctrl.game_over) return "R: play again";
	if (_ctrl.reveal_pending) return "SPACE: deal the next round";
	if (_ctrl.state == GAME_STATE.INPUTTING_BET) return "Click the arrows on a claim. ENTER confirms a higher bet.";
	if (_ctrl.state == GAME_STATE.WAITING_FOR_INPUT) return "B: raise      L: call bluff";
	if (_ctrl.state == GAME_STATE.BOT_THINKING) return "A bot is deciding...";
	if (_ctrl.state == GAME_STATE.SWITCHING_TURN) {
		if (_ctrl.is_bot[_ctrl.current_turn]) return "Next up is a bot.";
		return "SPACE: look at your cards";
	}
	return "";
}
