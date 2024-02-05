compute_ai_inputs :: (player : *Player) {
    if #complete ai_player.skill == {
        case .Moron;

            player2.left = 0;
            player2.right = 0;
            player2.down = 0;
            player2.up = 0;
            player2.power1 = 0;
            player2.power2 = 0;

        case .Mindless;

            compute_mindless_ai_inputs(player);

        case .Smart;

            compute_mindless_ai_inputs(player);
    }
}

#scope_file

compute_mindless_ai_inputs :: (player : *Player) {
    countdown(*ai_player.countdown);

    if ai_player.countdown > 0 {

        if ai_player.direction == 1 {
            player2.left = 0;
            player2.right = 1;
        } else if ai_player.direction == -1 {
            player2.left = 1;
            player2.right = 0;
        } else {
            player2.left = 0;
            player2.right = 0;
        }

    } else {

        // Change direction and reset countdown
        if ai_player.direction == 1 {
            ai_player.direction = 0;
            ai_player.countdown = 2*ai_player.COUNTDOWN;
            ai_player.direction_prev = 1;
        } else if ai_player.direction == -1 {
            ai_player.direction = 0;
            ai_player.countdown = 2*ai_player.COUNTDOWN;
            ai_player.direction_prev = -1;
        } else {
            ai_player.countdown = ai_player.COUNTDOWN;
            ai_player.direction = -ai_player.direction_prev;
        }

    }

    player2.down = 0;
    player2.up = 0;
    player2.power1 = 0;
    player2.power2 = 0;
}