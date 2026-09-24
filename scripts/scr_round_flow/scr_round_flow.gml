/// What happens after a bluff is called.
/// check_bet still decides true or false. This file only applies the penalty,
/// shows the cards that were bet on, and chooses who opens the next round.
/// reset_round is unchanged: it redeals a fresh 52 using each hand's length.

function count_living() {
	var _ctrl = obj_game_controller;
	var _n = 0;
	for (var i = 0; i < _ctrl.num_players; i++) {
		if (_ctrl.alive[i]) _n++;
	}
	return _n;
}

/// Next seat after _from who is still in the match.
function next_living_index(_from) {
	var _ctrl = obj_game_controller;
	var _i = _from;
	for (var n = 0; n < _ctrl.num_players; n++) {
		_i++;
		if (_i >= _ctrl.num_players) _i = 0;
		if (_ctrl.alive[_i]) return _i;
	}
	return _from;
}

function apply_round_loss(_loser_idx, _bet_was_true) {
	var _ctrl = obj_game_controller;
	var _bet = _ctrl.current_bet;
	var _claim = bet_to_text(_bet.category, _bet.value1, _bet.value2);
	var _who = seat_name(_loser_idx);

	// Snapshot before the penalty card, so the reveal is the pool that was judged.
	_ctrl.reveal_lines = [];
	for (var p = 0; p < _ctrl.num_players; p++) {
		var _label = seat_name(p);
		if (!_ctrl.alive[p]) {
			array_push(_ctrl.reveal_lines, _label + ": OUT");
			continue;
		}
		var _hand = _ctrl.hands[p];
		var _text = "";
		for (var c = 0; c < array_length(_hand); c++) {
			if (_text != "") _text += ", ";
			_text += _hand[c].get_name();
		}
		if (_text == "") _text = "(no cards)";
		array_push(_ctrl.reveal_lines, _label + ": " + _text);
	}

	if (_bet_was_true) {
		_ctrl.reveal_header = _claim + " was TRUE. " + _who + " takes a card.";
	} else {
		_ctrl.reveal_header = _claim + " was a BLUFF. " + _who + " takes a card.";
	}

	// Length is the next deal count. The extra card is thrown away when the deck is rebuilt.
	var _new_size = array_length(_ctrl.hands[_loser_idx]) + 1;
	if (_new_size >= _ctrl.lose_condition) {
		_ctrl.alive[_loser_idx] = false;
		_ctrl.hands[_loser_idx] = [];
		_ctrl.reveal_header += " " + _who + " is out.";
		_ctrl.event_log += " " + _who + " is out.";
	} else {
		array_push(_ctrl.hands[_loser_idx], new Card(SUIT.DIAMONDS, 1));
	}

	_ctrl.current_bet = new Bet(POKER_HAND.HIGH_CARD, 0, 0, -1);
	_ctrl.reveal_pending = true;

	if (count_living() <= 1) {
		_ctrl.game_over = true;
		_ctrl.winner_index = -1;
		for (var i = 0; i < _ctrl.num_players; i++) {
			if (_ctrl.alive[i]) {
				_ctrl.winner_index = i;
				break;
			}
		}
		if (_ctrl.winner_index != -1) {
			var _winner = seat_name(_ctrl.winner_index);
			_ctrl.event_log = _winner + " wins.";
			_ctrl.reveal_header += " " + _winner + " wins.";
		}
		_ctrl.state = GAME_STATE.SWITCHING_TURN;
		show_debug_message(_ctrl.reveal_header);
		return;
	}

	if (_ctrl.alive[_loser_idx]) {
		_ctrl.current_turn = _loser_idx;
	} else {
		_ctrl.current_turn = next_living_index(_loser_idx);
	}
	_ctrl.state = GAME_STATE.SWITCHING_TURN;
	show_debug_message(_ctrl.reveal_header);
}
