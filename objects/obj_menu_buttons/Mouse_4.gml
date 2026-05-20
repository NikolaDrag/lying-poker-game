// Each instance of the button object is at (0,0) 
// and has the SAME giant rectangle hitbox.
// We use the mouse's Y position to filter the click.

var _my = mouse_y;

switch (image_index) {
    case 0: // NEW GAME
        if (_my >= 2335 && _my <= 2535) { // These match your current screenshot!
            room_goto(Room1);
        }
        break;
        
    case 1: // OPTIONS
        if (_my >= 2650 && _my <= 2875) { // Guessing heights - check your sprite!
            show_message_async("Options: \n1. Music: ON\n2. Difficulty: Hard");
        }
        break;
        
    case 2: // QUIT
        if (_my >= 2975 && _my <= 3200) { // Guessing heights
            game_end();
        }
        break;
}