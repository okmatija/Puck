[x] Merge with main
[x] Use local versions of the GetRect and Simp modules
[x] Fix issue where client is initializing box2d
[ ] Fix crash when client leaves game
[ ] Send the transform for the level obstructions
[ ] Add winning conditions
[ ] Add an option for game mode e.g., best of/first to/rally (high scores)
[ ] Add text to all the game settings
[ ] Add color and player name customization
[ ] Make pausing a quitting the game work better


# Why/What?

A pong game to play at work in breaks

# General

[x] Add a basic menu
[x] Add an option to toggle the ball type
[x] Add an option to toggle the paddle type
[x] Add an option to set the level/obstruction type
[x] Add an option to set the socket address (aka ip_address:port_number)
[ ] Add a restart button
[ ] Options to have the window always on top
[ ] Add Credits

# Payment

[ ] $1.00 purchase cost, get 2 licenses per purchase? to play in 2 player mode. Some fraction to charity? $0.25 per invite after that?
[ ] Database for user accounts etc

# Sound

[x] Listen to physics contacts
[x] Play hit sound

# Rendering

[ ] Color the ball based on how it is spinning e.g., CW/CCW
[ ] Fake higher framerates by rendering the sweep of the ball

# Networking

[ ] Use more than one ENet channel.  From the features page: Since ENet will stall delivery of reliable packets to ensure proper sequencing, and consequently any packets of higher sequence number whether reliable or unreliable, in the event the reliable packet's predecessors have not yet arrived, this can introduce latency into the delivery of other packets which may not need to be as strictly ordered with respect to the packet that stalled their delivery.  To combat this latency and reduce the ordering restrictions on packets, ENet provides multiple channels of communication over a given connection. Each channel is independently sequenced, and so the delivery status of a packet in one channel will not stall the delivery of other packets in another channel.
[ ] Implment Snapshot Interpolation. This does physics simulation only on the server, which is good since we don't rely on phyics running on clients (mobile?)
[ ] Use bounding and quantization to send floating point numbers to the clients (we know max velocity of paddle, then we can quanitize that range and send an integer and reverse the process on the client)
[ ] Think about packet size in bytes and how many packets per second we will send (ie determine bandwidth)
[ ] Error checking for port numbers etc
[ ] Aim for latency of 50ms max, 
[ ] Support up to 4 players on differently shaped game boards
[ ] Basic network play
[ ] Get a free invite code when you buy a copy
[ ] How to implement auto updates
[ ] How does alignment affect networking??

    // The size of a struct, measured in bytes of memory, includes enough storage for all
    // its elements, including potential padding between elements. Different platforms
    // may have different alignment requirements. So your struct could end up being different
    // sizes on different target machines, *but*, you are able to query everything about the struct
    // and know these facts at compile time.
    // 
    // Furthermore, you can control padding and alignment manually with compiler directives,
    // which we'll talk about much later in a different file.

# Controls

[x] Basic mouse control
[x] Add acceleration to the paddle
[ ] Curve to the ball (applying a force) player motion after the ball was hit
[ ] Add serving the ball?
[ ] Add tilt/rotate button

# Gameplay

[x] Kinematic obstructions in the play area
[ ] Get 3 boosts which gradually replenish, its useful to reach for ball when its going really fast
[ ] Make the paddle out of edge elements so you have finer control over the shape
[ ] Maybe there should be an option to play as a the "level/game master" who gets to control the level e.g., how fast things spin etc. Create fun situations where someone can play favourites
[ ] Should be able to launch a ball from your paddle, to make it easier to create the fun situations where you can hit a ball with another ball
[ ] Slow time powerup to temporarily slow down time
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

---

Investigate possible UDP conjestion:


jmpy_91: Welcome back
jmpy_91: I did some playing around, still not sure it is actual congestion 
:D
 https://pasteboard.co/ph7nV5OmzmzK.png
jmpy_91: but definitely something weird going on
jmpy_91: let's follow the get it working plan
jmpy_91: thats on a vm local traffic
jmpy_91: it is showing we are getting way more throughput than the packet per frame
jmpy_91: its a testing tool, its not jai
jmpy_91: something you could do is record the traffic with wireshark how your packets look
jmpy_91: or you can get it working and do that investigation some other time
jmpy_91: 
:)