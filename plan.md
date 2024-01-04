Menu flow for main game:

    [ Play Local Game ]
          [  Ball ]
          [ Paddle]
          [ Level ]
        [Back] [Play]
    [Join Network Game]
          [IP:Port]
        [Back] [Join]
    [Host Network Game]
          <IP:Port>
          [  Ball ]
          [ Paddle]
          [ Level ]
          [Players]
        [Back] [Play]
    [Settings]
        [Left  Key]
        [Right Key]
        [Boost Key]
          [Back]
    [Quit]

Pause menu:
       [Settings]
    [Resume] [Leave]


When hosting a game, you can play alone until the other player joins
When either player presses Esc during the game it pauses everywhere


// wait for all client inputs
// simulate
// send new game state to all clients

Client_Input :: struct {
    left_down : bool;
    right_down : bool;
}


// TODO Use notes to generate entries of the Game_State struct
Game_State :: struct {
    Player_State :: struct {
        position_x : float;
    };

    player1 : Player_State;
    player2 : Player_State;

    Ball_State :: struct {
        position : Vector2;
        velocity : Vector2;
    };

    ball : Vector2;
}

game_state : Game_State;
















A pong game to play at work in breaks

# General

[x] Add a basic menu
[ ] @TODOOO Use local versions of the GetRect and Simp modules
[ ] Add a restart button
[ ] Options to have the window always on top
[ ] Add an option to toggle the ball type

[ ] Add an option to toggle the paddle type
[ ] Add an option to set the level/obstruction type
[ ] Add an option to set the socket address (aka ip_address:port_number)
[ ] Add an option for game mode e.g., best of/first to/rally (high scores)

# Payment

[ ] $1.00 purchase cost, 2 invites per purchase? with some fraction to charity. $0.25 per invite after that?
[ ] Database for user accounts etc

# Sound

[x] Listen to physics contacts
[x] Play hit sound

# Rendering

[ ] Color the ball based on how it is spinning e.g., CW/CCW
[ ] Fake higher framerates by rendering the sweep of the ball

# Networking

[ ] Implment Snapshot Interpolation. This does physics simulation only on the server, which is good since we don't rely on phyics running on clients (mobile?)
[ ] Use bounding and quantization to send floating point numbers to the clients (we know max velocity of paddle, then we can quanitize that range and send an integer and reverse the process on the client)
[ ] Think about packet size in bytes and how many packets per second we will send (ie determine bandwidth)
[ ] Aim for latency of 50ms max, 
[ ] Support up to 4 players on differently shaped game boards
[ ] Basic network play
[ ] Get a free invite code when you buy a copy
[ ] How to implement auto updates

# Controls

[x] Basic mouse control
[x] Add acceleration to the paddle
[ ] Curve to the ball (applying a force) player motion after the ball was hit
[ ] Add serving the ball?
[ ] Add tilt/rotate button

# Gameplay

[x] Kinematic obstructions in the play area
[ ] Three balls was really fun (Will playtest)
[ ] Countdown to unpause
[ ] Implement a simple AI
[ ] Sharp corners are bad because its hard to predict what the ball will do when it collides, which feels bad
[ ] Show the short term predicted trajectory of the ball?
[ ] Gradually add the slope to the paddles as you play the game since otherwise you can slam it really hard and win right away
[ ] Gradually change the ball shape as the game progresses, to become more boxy?
[ ] Divide paddles into thirds and have each third have different coeffs of restitution
[ ] Two parallel channels in the level with very high coeff of restitution inside them
[ ] Powerups as goal posts which change the property of the ball
[ ] Powerup to change the shape of the paddle
[ ] Change ball shape e.g., circle, square, elipsoid, hexagon, square with rounded corners?
[ ] Powerup to make the other player smooth so they can't do spin shots. get powerups by
[ ] Add lateral (left/right) boost: if ball bounces during lateral boost add ball spin
[ ] Add vertical/jump (boost): if ball bounces during jump boost increase ball speed
[ ] Experiment with no colliding balls?


# Weird

[ ] Add little legs to the paddle, upgrading these makes them bigger chad legs and you can accelerate faster

# Notes
- To hit the ball really fast you can hit it with the side of the paddle, but to do that you need to risk missing the ball entirely which is neat

# DONE

[x] Add local Player2
[x] Add text keeping score
[x] Move player 1 panel left and right
[x] Switch to MKS units (meters/kilograms/seconds)
[x] Add ball
[x] Investigate stream static at ~2h 27min
[x] Box2D physics for movement and ball
[x] What kind of Box2D body to use for the player?
[x] Tweak the scale of things so the physics works well
[x] Use b2EdgeShape for play edges



















---

Things to report on Jai discord:

[ ] Why does `jai first.jai...` work? adding dots to the end of the file name is allowed?
[ ] modules/std_vorbis/windows.jai and JaiBox2D/module.jai both export type declarations like uint8 :: u8, which causes errors, can the compiler realize these are the same? or do we need to make the definition file scoped (what I did in JaiBox2D). Its a bit confusing to be able to access a private via a different declaration
[ ] Suggest a bounty for adding Box2D bindings/module
[ ] Suggest a bounty for adding line rendering to Simp

Projects to work on:
[ ] Implement a Box2D dependency extractor where your confidence on how well you understand dependencies is encoded in box thicknesses


---

Notes from frame-rate-independence talk

- have framerate be really high and consistent so that you minimize problems related to reading player input at slow/variable dts, which leads to the game feeling bad
- Use exact evaluation when possible so you can make sim(sim(state_0, dt), dt) == sim(state_0, 2dt)
- Suggest adding nice line rendering to Simp as a bounty?

Box2D notes:

// use MKS units (meter-kilogram-second)
// handle tunneling by finding first time of impact (TOI), then sub-step to that time and then resolve the collision


---

Random notes:

- I try my very hardest to not have typing be a factor in making a program. If something is better but requires more typing, I do it. I've noticed what Jon says about autocomplete to be true for me. It encourages you to think on a fragment-by-fragment level instead of a "paragraphs" level. Waiting for the autocomplete to tell you what you need versus having the program cached in your head

- Interesting discord message about windows app icons: https://discord.com/channels/661732390355337246/784843664651190273/1184147188989833277

- better than GJK? https://discord.com/channels/661732390355337246/661732390355337249/1063251664691282011

- P2P https://discord.com/channels/661732390355337246/661732390355337249/1183947470443647016

---

Make a mobile app for twitch chats, make it flash when you get a new message so when you stream you can use your phone to read the chat and you don't miss things

