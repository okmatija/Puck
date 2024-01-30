// Compute data to convert world data to screen data
// * _screen is the postfix for screen coordinates
// * _world  is the postfix for world  coordinates
// * _pixels is the postfix for screen vectors
// * _meters is the postfix for world  vectors
get_world_to_screen_data :: () -> float, Vector2 {
    game_size := get_game_size();
    game_aspect := game_size.x / game_size.y;
    window_aspect := cast(float)window_width / cast(float)window_height;

    // Scale the game until it fits tightly in the window while keeping its aspect ratio
    // letter/pillarboxing will be used to fill in the remaining space. We only need to
    // consider aspect ratios (imagine of the game box scaling up from zero until it fits
    // in the window box)

    meters_to_pixels : float;
    offset_pixels : Vector2;
    if game_aspect < window_aspect {
        meters_to_pixels = window_height / (2 * game_size.y);
        offset_pixels.x = (window_width - 2 * game_size.x * meters_to_pixels) / 2;
    } else {
        meters_to_pixels = window_width / (2 * game_size.x);
        offset_pixels.y = (window_height - 2 * game_size.y * meters_to_pixels) / 2;
    }

    return meters_to_pixels, offset_pixels;
}

world_to_screen :: (point_world : Vector2) -> Vector2 {
    game_size := get_game_size();
    meters_to_pixels, offset_pixels := get_world_to_screen_data();
    return offset_pixels + (game_size + point_world) * meters_to_pixels;
}

screen_to_world :: (point_screen : Vector2) -> Vector2 {
    game_size := get_game_size();
    meters_to_pixels, offset_pixels := get_world_to_screen_data();
    return (point_screen - offset_pixels) / meters_to_pixels - game_size;
}