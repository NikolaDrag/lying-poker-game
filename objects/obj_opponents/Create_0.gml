// 1. Basic Animation Control
image_speed = 0; // CRITICAL: Stops the gnomes from cycling through 1, 2, 3 players

// 2. Find the Controller to get the Player Count
var _inst = instance_find(obj_game_controller, 0);

// If the controller exists, get the count. Otherwise, default to 1 opponent.
var _num_players = (_inst != noone) ? _inst.num_players : 2;

// 3. Set the Visuals
// Since your sprite is named "spr_opponents", we use image_index (the frame)
sprite_index = spr_opponents; 

image_index = _num_players - 2; 

x = 0; // Dead center of the room width
y = 0; // Positioned above the table line (Duska)
