/// Bot decisions for one seat.
/// Reads its own cards and the current claim, then either calls call_liar or
/// submits a raise that already passes is_bet_valid_increase.
/// Personalities are rolled once per match so a seat stays cautious or loose.
///
/// These ranges are mirrored in tests/liar_poker_sim.py.
#macro BOT_TRUST_MIN 0.28
#macro BOT_TRUST_MAX 0.78
#macro BOT_BLUFF_MIN 0.08
#macro BOT_BLUFF_MAX 0.28
#macro BOT_JUMP_MIN 0.12
#macro BOT_JUMP_MAX 0.40
#macro BOT_IMPULSE_CALL 0.03
#macro BOT_STUBBORN_RIDE 0.055

function bot_make_personality() {
	return {
		trust: random_range(BOT_TRUST_MIN, BOT_TRUST_MAX),
		bluff_rate: random_range(BOT_BLUFF_MIN, BOT_BLUFF_MAX),
		jumpiness: random_range(BOT_JUMP_MIN, BOT_JUMP_MAX)
	};
}

function bot_power_values() {
	return [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1];
}

function bot_straight_starts() {
	return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
}

function bot_next_rank_up(_v) {
	if (_v == 13 || _v == 1) return 1;
	return _v + 1;
}

function bot_binom(_n, _k) {
	if (_k < 0 || _n < 0 || _k > _n) return 0;
	if (_k == 0 || _k == _n) return 1;
	if (_k > _n - _k) _k = _n - _k;
	var _r = 1;
	for (var i = 1; i <= _k; i++) {
		_r = _r * (_n - _k + i) / i;
	}
	return _r;
}

/// Chance of drawing at least _need successes.
function bot_hyper_at_least(_pop, _success_states, _draws, _need) {
	if (_need <= 0) return 1;
	if (_need > _draws || _need > _success_states || _pop <= 0) return 0;
	if (_draws > _pop) _draws = _pop;
	var _den = bot_binom(_pop, _draws);
	if (_den <= 0) return 0;
	var _fail = _pop - _success_states;
	var _num = 0;
	var _max_i = min(_success_states, _draws);
	for (var i = _need; i <= _max_i; i++) {
		var _rest = _draws - i;
		if (_rest > _fail) continue;
		_num += bot_binom(_success_states, i) * bot_binom(_fail, _rest);
	}
	return _num / _den;
}

function bot_hyper_groups_rec(_groups, _need, _draws_left, _fail, _index) {
	if (_index >= array_length(_groups)) {
		if (_draws_left < 0 || _draws_left > _fail) return 0;
		return bot_binom(_fail, _draws_left);
	}
	var _sum = 0;
	var _g = _groups[_index];
	var _n = _need[_index];
	var _max_i = min(_g, _draws_left);
	for (var i = _n; i <= _max_i; i++) {
		_sum += bot_binom(_g, i) * bot_hyper_groups_rec(_groups, _need, _draws_left - i, _fail, _index + 1);
	}
	return _sum;
}

/// Multivariate: each group is a distinct set of remaining cards, each with its own minimum.
function bot_hyper_groups(_pop, _groups, _need, _draws) {
	if (_draws < 0 || _pop < 0) return 0;
	if (_draws > _pop) return 0;
	// A negative "need" means the bot already holds those cards.
	var _groups_c = [];
	var _need_c = [];
	var _need_sum = 0;
	var _used = 0;
	for (var g = 0; g < array_length(_groups); g++) {
		var _g = _groups[g];
		var _n = _need[g];
		if (_g < 0) _g = 0;
		if (_n < 0) _n = 0;
		if (_n > _g) return 0;
		array_push(_groups_c, _g);
		array_push(_need_c, _n);
		_need_sum += _n;
		_used += _g;
	}
	_groups = _groups_c;
	_need = _need_c;
	if (_need_sum > _draws) return 0;
	if (_need_sum <= 0) return 1;
	var _den = bot_binom(_pop, _draws);
	if (_den <= 0) return 0;
	var _fail = _pop - _used;
	if (_fail < 0) return 0;
	return bot_hyper_groups_rec(_groups, _need, _draws, _fail, 0) / _den;
}

function bot_min_cards(_cat) {
	switch (_cat) {
		case POKER_HAND.HIGH_CARD: return 1;
		case POKER_HAND.PAIR: return 2;
		case POKER_HAND.THREE_KIND: return 3;
		case POKER_HAND.FOUR_KIND: return 4;
		case POKER_HAND.TWO_PAIR: return 4;
		case POKER_HAND.FULL_HOUSE: return 5;
	}
	return 5;
}

function bot_count_hand(_hand) {
	var _ranks = array_create(14, 0);
	var _suits = array_create(4, 0);
	var _matrix = array_create(4);
	for (var s = 0; s < 4; s++) _matrix[s] = array_create(14, 0);
	for (var i = 0; i < array_length(_hand); i++) {
		var _c = _hand[i];
		_ranks[_c.value]++;
		_suits[_c.suit]++;
		_matrix[_c.suit][_c.value]++;
	}
	return { ranks: _ranks, suits: _suits, matrix: _matrix };
}

function bot_straight_ranks(_start) {
	var _ranks = [];
	for (var k = 0; k < 5; k++) {
		var _cv = _start + k;
		if (_cv > 13) _cv -= 13;
		array_push(_ranks, _cv);
	}
	return _ranks;
}

/// How likely the claim is, given only this bot's cards. 0 and 1 are certain.
function bot_claim_probability(_hand, _total_cards, _cat, _v1, _v2) {
	var _my = array_length(_hand);
	var _k = _total_cards - _my;
	if (_k < 0) _k = 0;
	if (_total_cards < bot_min_cards(_cat)) return 0;

	var _info = bot_count_hand(_hand);
	var _pop = 52 - _my;
	if (_pop < 0) _pop = 0;

	if (_cat == POKER_HAND.FLUSH) {
		var _held_s = _info.suits[_v1];
		return bot_hyper_at_least(_pop, 13 - _held_s, _k, 5 - _held_s);
	}

	if (_cat == POKER_HAND.HIGH_CARD || _cat == POKER_HAND.PAIR || _cat == POKER_HAND.THREE_KIND || _cat == POKER_HAND.FOUR_KIND) {
		var _need_n = 1;
		if (_cat == POKER_HAND.PAIR) _need_n = 2;
		if (_cat == POKER_HAND.THREE_KIND) _need_n = 3;
		if (_cat == POKER_HAND.FOUR_KIND) _need_n = 4;
		var _held_r = _info.ranks[_v1];
		return bot_hyper_at_least(_pop, 4 - _held_r, _k, _need_n - _held_r);
	}

	if (_cat == POKER_HAND.TWO_PAIR || _cat == POKER_HAND.FULL_HOUSE) {
		if (_v1 == _v2) return 0;
		var _need_a = (_cat == POKER_HAND.FULL_HOUSE) ? 3 : 2;
		var _need_b = 2;
		var _ga = 4 - _info.ranks[_v1];
		var _gb = 4 - _info.ranks[_v2];
		return bot_hyper_groups(_pop, [_ga, _gb], [_need_a - _info.ranks[_v1], _need_b - _info.ranks[_v2]], _k);
	}

	var _ranks = bot_straight_ranks(_v1);
	if (_cat == POKER_HAND.STRAIGHT) {
		var _groups = [];
		var _needs = [];
		for (var i = 0; i < 5; i++) {
			var _held = _info.ranks[_ranks[i]];
			var _from_others = 1 - _held;
			if (_from_others < 0) _from_others = 0;
			array_push(_groups, 4 - _held);
			array_push(_needs, _from_others);
		}
		return bot_hyper_groups(_pop, _groups, _needs, _k);
	}

	// Straight flush and royal flush: five exact cards.
	var _suit = (_cat == POKER_HAND.ROYAL_FLUSH) ? _v1 : _v2;
	if (_cat == POKER_HAND.ROYAL_FLUSH) _ranks = [10, 11, 12, 13, 1];
	var _g2 = [];
	var _n2 = [];
	for (var j = 0; j < 5; j++) {
		var _held_c = _info.matrix[_suit][_ranks[j]];
		var _left = 1 - _held_c;
		if (_left < 0) _left = 0;
		array_push(_g2, _left);
		var _need_c = 1 - _held_c;
		if (_need_c < 0) _need_c = 0;
		array_push(_n2, _need_c);
	}
	return bot_hyper_groups(_pop, _g2, _n2, _k);
}

function bot_push_bet(_out, _limit, _ctrl, _cat, _v1, _v2) {
	if (array_length(_out) >= _limit) return false;
	if (_ctrl.is_bet_valid_increase(_cat, _v1, _v2)) {
		array_push(_out, { cat: _cat, v1: _v1, v2: _v2 });
	}
	return true;
}

/// The next few legal raises, lowest first, using the existing hierarchy.
function bot_collect_raises(_ctrl, _limit) {
	var _out = [];
	var _vals = bot_power_values();
	var _starts = bot_straight_starts();
	var _vi, _si, _vj;

	for (_vi = 0; _vi < array_length(_vals); _vi++) {
		if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.HIGH_CARD, _vals[_vi], 0)) return _out;
	}
	for (_vi = 0; _vi < array_length(_vals); _vi++) {
		if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.PAIR, _vals[_vi], 0)) return _out;
	}
	for (_vi = 0; _vi < array_length(_vals); _vi++) {
		for (_vj = 0; _vj < array_length(_vals); _vj++) {
			if (_vals[_vj] == _vals[_vi]) continue;
			if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.TWO_PAIR, _vals[_vi], _vals[_vj])) return _out;
		}
	}
	for (_vi = 0; _vi < array_length(_vals); _vi++) {
		if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.THREE_KIND, _vals[_vi], 0)) return _out;
	}
	for (_si = 0; _si < 4; _si++) {
		if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.FLUSH, _si, 0)) return _out;
	}
	for (_vi = 0; _vi < array_length(_starts); _vi++) {
		if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.STRAIGHT, _starts[_vi], 0)) return _out;
	}
	for (_vi = 0; _vi < array_length(_vals); _vi++) {
		for (_vj = 0; _vj < array_length(_vals); _vj++) {
			if (_vals[_vj] == _vals[_vi]) continue;
			if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.FULL_HOUSE, _vals[_vi], _vals[_vj])) return _out;
		}
	}
	for (_vi = 0; _vi < array_length(_vals); _vi++) {
		if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.FOUR_KIND, _vals[_vi], 0)) return _out;
	}
	for (_vi = 0; _vi < array_length(_starts); _vi++) {
		for (_si = 0; _si < 4; _si++) {
			if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.STRAIGHT_FLUSH, _starts[_vi], _si)) return _out;
		}
	}
	for (_si = 0; _si < 4; _si++) {
		if (!bot_push_bet(_out, _limit, _ctrl, POKER_HAND.ROYAL_FLUSH, _si, 0)) return _out;
	}
	return _out;
}

function bot_hand_supports(_hand, _bet) {
	var _cat = _bet.cat;
	var _v1 = _bet.v1;
	var _v2 = _bet.v2;
	var _info = bot_count_hand(_hand);

	if (_cat == POKER_HAND.FLUSH || _cat == POKER_HAND.ROYAL_FLUSH) return _info.suits[_v1] > 0;
	if (_cat == POKER_HAND.STRAIGHT || _cat == POKER_HAND.STRAIGHT_FLUSH) {
		var _ranks = bot_straight_ranks(_v1);
		for (var i = 0; i < array_length(_ranks); i++) {
			if (_cat == POKER_HAND.STRAIGHT_FLUSH) {
				if (_info.matrix[_v2][_ranks[i]] > 0) return true;
			} else if (_info.ranks[_ranks[i]] > 0) {
				return true;
			}
		}
		return false;
	}
	if (_cat == POKER_HAND.TWO_PAIR || _cat == POKER_HAND.FULL_HOUSE) {
		return (_info.ranks[_v1] > 0 || _info.ranks[_v2] > 0);
	}
	return (_info.ranks[_v1] > 0);
}

function bot_choose_raise(_ctrl, _hand, _persona) {
	var _options = bot_collect_raises(_ctrl, 16);
	var _count = array_length(_options);
	if (_count == 0) return undefined;

	var _supported = [];
	for (var i = 0; i < _count; i++) {
		if (bot_hand_supports(_hand, _options[i])) array_push(_supported, i);
	}

	var _idx = 0;
	var _roll = random(1);
	if (_roll < _persona.bluff_rate) {
		// A step or two past the minimum, often a claim this hand does not help.
		_idx = irandom_range(min(1, _count - 1), _count - 1);
	} else if (_roll < _persona.bluff_rate + _persona.jumpiness) {
		_idx = min(2, _count - 1);
	} else if (array_length(_supported) > 0 && _supported[0] <= 10) {
		_idx = _supported[0];
	}

	return _options[_idx];
}

function bot_call_bar(_cat, _trust) {
	// Low claims are usually true once a few cards are out, so the bar stays low.
	// Big claims have to look likely or the bot calls.
	var _lo = 0.48;
	var _hi = 0.22;
	if (_cat == POKER_HAND.HIGH_CARD) {
		_lo = 0.10;
		_hi = 0.04;
	} else if (_cat == POKER_HAND.PAIR) {
		_lo = 0.32;
		_hi = 0.12;
	} else if (_cat <= POKER_HAND.THREE_KIND) {
		_lo = 0.38;
		_hi = 0.16;
	}
	return lerp(_lo, _hi, _trust);
}

function bot_wants_to_call(_p, _bet, _persona, _ctrl) {
	// A small chance to call a fine bet, or to let a shaky one go. Not a solver.
	if (random(1) < BOT_IMPULSE_CALL) return true;
	if (random(1) < BOT_STUBBORN_RIDE) return false;
	if (_p <= 0.02) return true;

	var _noisy = clamp(_p * random_range(0.88, 1.12), 0, 1);
	var _bar = bot_call_bar(_bet.category, _persona.trust);

	var _bidder = _bet.better_index;
	if (_bidder >= 0 && _bidder < _ctrl.num_players) {
		var _bc = array_length(_ctrl.hands[_bidder]);
		if (_bc >= 5) _bar -= 0.04;
		if (_bc <= 1 && _bet.category >= POKER_HAND.PAIR) _bar += 0.06;
	}
	return _noisy < _bar;
}

function bot_submit(_ctrl, _me, _cat, _v1, _v2, _verb) {
	if (!_ctrl.is_bet_valid_increase(_cat, _v1, _v2)) return false;
	_ctrl.current_bet = new Bet(_cat, _v1, _v2, _me);
	_ctrl.event_log = seat_name(_me) + " " + _verb + ": " + bet_to_text(_cat, _v1, _v2);
	push_bet_log(seat_name(_me) + ": " + bet_to_text(_cat, _v1, _v2));
	show_debug_message(_ctrl.event_log);
	next_turn();
	return true;
}

function bot_play_opening(_ctrl, _me, _hand, _persona) {
	var _info = bot_count_hand(_hand);
	var _best = 2;
	var _best_power = -1;
	var _max = 0;
	var _best_suit = 0;
	var _max_suit = 0;

	for (var i = 0; i < array_length(_hand); i++) {
		var _c = _hand[i];
		var _pow = (_c.value == 1) ? 14 : _c.value;
		if (_info.ranks[_c.value] > _max || (_info.ranks[_c.value] == _max && _pow > _best_power)) {
			_max = _info.ranks[_c.value];
			_best = _c.value;
			_best_power = _pow;
		}
	}
	for (var s = 0; s < 4; s++) {
		if (_info.suits[s] > _max_suit) {
			_max_suit = _info.suits[s];
			_best_suit = s;
		}
	}
	if (array_length(_hand) == 0) {
		_best = irandom_range(1, 13);
		_max = 0;
	}

	var _cat = POKER_HAND.HIGH_CARD;
	var _v1 = _best;
	var _v2 = 0;

	if (_max >= 2) {
		_cat = POKER_HAND.PAIR;
		if (random(1) < _persona.bluff_rate * 0.45) _cat = POKER_HAND.THREE_KIND;
	} else if (array_length(_hand) >= 4 && _max_suit >= 3 && random(1) < _persona.bluff_rate) {
		_cat = POKER_HAND.FLUSH;
		_v1 = _best_suit;
	} else if (random(1) < _persona.bluff_rate) {
		_cat = POKER_HAND.PAIR;
	} else if (random(1) < 0.22) {
		_v1 = bot_next_rank_up(_best);
	}

	if (bot_submit(_ctrl, _me, _cat, _v1, _v2, "opens")) return;

	var _opts = bot_collect_raises(_ctrl, 1);
	if (array_length(_opts) > 0 && bot_submit(_ctrl, _me, _opts[0].cat, _opts[0].v1, _opts[0].v2, "opens")) return;
	next_turn();
}

function bot_take_turn() {
	var _ctrl = obj_game_controller;
	var _me = _ctrl.current_turn;
	if (_me < 0 || _me >= _ctrl.num_players || !_ctrl.alive[_me]) {
		next_turn();
		return;
	}

	var _hand = _ctrl.hands[_me];
	var _bet = _ctrl.current_bet;
	var _persona = _ctrl.bot_personality[_me];

	if (_bet.better_index == -1) {
		bot_play_opening(_ctrl, _me, _hand, _persona);
		return;
	}

	var _total = 0;
	for (var i = 0; i < _ctrl.num_players; i++) _total += array_length(_ctrl.hands[i]);
	var _p = bot_claim_probability(_hand, _total, _bet.category, _bet.value1, _bet.value2);

	if (bot_wants_to_call(_p, _bet, _persona, _ctrl)) {
		_ctrl.event_log = seat_name(_me) + " calls bluff.";
		show_debug_message(_ctrl.event_log);
		call_liar(_me);
		return;
	}

	var _raise = bot_choose_raise(_ctrl, _hand, _persona);
	if (is_undefined(_raise) || !bot_submit(_ctrl, _me, _raise.cat, _raise.v1, _raise.v2, "raises")) {
		_ctrl.event_log = seat_name(_me) + " calls bluff.";
		show_debug_message(_ctrl.event_log);
		call_liar(_me);
	}
}
