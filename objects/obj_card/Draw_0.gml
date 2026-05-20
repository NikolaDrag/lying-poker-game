// Stop the card from cycling through all 52 frames like a GIF
image_speed = 0;

// Only draw if we actually have data assigned
if (card_data != undefined) {
	//kartite v sprite pochvat ot 0, koq snimka da displayne
    var _frame = (card_data.suit * 13) + (card_data.value - 1); 
	
	//take the sprite, find the frame in the sprite, draw it to those coordinates
    draw_sprite(sprite_cards, _frame, x, y);
}else {
    // Optional: Draw a "loading" or "error" version if data is missing
    draw_text(x, y, "NO DATA");
}