// Each instance of the button object is at (0,0) 
// and has the SAME giant rectangle hitbox.
// We use the mouse's Y position to filter the click.

// One instance handles the speaker. The other copies of this object would toggle it again.
if (image_index == 0 && music_click_buttons()) exit;

// The setup panel is on top. Don't let New Game, Options, or Quit click through it.
if (instance_exists(obj_match_setup)) exit;

var _my = mouse_y;

switch (image_index) {
    case 0: // NEW GAME
        if (_my >= 2335 && _my <= 2535) { // These match your current screenshot!
            instance_create_layer(0, 0, "Instances", obj_match_setup);
        }
        break;
        
    case 1: // OPTIONS opens the same style of panel as New Game.
        if (_my >= 2580 && _my <= 2960) {
            if (!instance_exists(obj_match_setup)) {
                global.panel_mode = "options";
                instance_create_layer(0, 0, "Instances", obj_match_setup);
            }
        }
        break;
        
    case 2: // QUIT
        if (_my >= 2975 && _my <= 3200) { // Guessing heights
            game_end();
        }
        break;
}