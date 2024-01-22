# Why/What?

A pong game to play at work in breaks

# General

[ ] Add winning conditions
[ ] Add an option for game mode e.g., best of/first to/rally (high scores)
[ ] Add color and player name customization
[ ] Make pausing a quitting the game work better
[ ] Add a restart button
[ ] Options to have the window always on top
[ ] Add Credits

[x] Add text to all the game settings
[x] Add a basic menu
[x] Add an option to toggle the ball type
[x] Add an option to toggle the paddle type
[x] Add an option to set the level/obstruction type
[x] Add an option to set the socket address (aka ip_address:port_number)
[x] Merge with main
[x] Use local versions of the GetRect and Simp modules

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

[x] Make host game choices propogate to clients
[x] Fix issue where client is initializing box2d
[x] Send the transform for the level obstructions
[x] Experiment with how often clients and servers send packets
[x] Fix crash when client leaves game
[-] When disconnecting do we need to flush before we destroy the host?
[ ] @Think WHY do we want to sent input/game state reliably?? (does reliable => acknowledged?)
[ ] @Bug When the client disconnects without notifying the server it does not timeout. Also gets very unresponsive...!
[ ] Reduce the timeout duration on client/server disconnect?
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
[ ] Portals?
[ ] Ball can have gravitational attraction to the powerups? And the powerups only attach to that specific ball? 
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

# DevX

[ ] Add imgui for debug UI to the project, consider using https://github.com/kevinw/jai-imgui as a starting point for the backend implementation using Window_Creation and Input modules. Then use this to implement debugging for enet in Pong


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


