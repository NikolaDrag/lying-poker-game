if (voice != -1) audio_stop_sound(voice);
if (song != -1) audio_destroy_stream(song);
if (icon != -1) sprite_delete(icon);
