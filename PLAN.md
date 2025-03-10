# Why/What?

A pong game to play at work in breaks
Starting competitive mobile e-sports!
Pong/BlockBreaker/RocketLeague/JBlows billiards game

# Mindless cleanup

* Enforce struct_operation naming convention? e.g., player_deinit, player_init etc...

# General

* Maryna suggests making the dome circles visible somehow, that could actually look pretty cool...
* make charge button and jump on next collision? make balls get damaged by impulses/energy so its possible to destroy the ball if you hit it too hard or if you hit a damaged ball too hard?
* Just have a three letter joining code and broadcast UPD to the entire network
* Show the balls loading into the game area
* Have explosions of any kind do damage to an area, so you can't just sit and protect a life
* Fix issue where the incoming laser passes through obstructions
* Fix issue where the incoming laser is shown when the ball just misses the paddle
* Fix issue where if the balls always miss both paddles, the results are not symmetric for P1/P2
* Fix crash when you leave a game with an empty level
* Add friction to the bottom of the paddle

* Have a speed up as well as a slow down? Maybe this would also need a world for things moving toward P1 and toward P2?
* Warp should be limited, maybe a fixed amount for the whole game, and you get more by exploding your own ball? e.g., to sacrifice something you get something
* Balls should not spin, use SetAngularDamping function to stop that
* Balls should take damage when being in a goal so they can't stay there forever
* Balls taking damage from moving too fast should have their speed reduced after the damaging collision
* Maybe the balls coming from left/right are the ones for P1/P2...
* Launch balls from left and right in alternating direction, have a shape that directs the ball from one side to the other. Maybe have a button that launches a 


    |\
    | \
    |  \
    |   \
    +....+

* Three full line of textured boxes for lives behind the player, so you can get a really damaging ball in a tunnel. Maybe the front row have more health so balls can get trapped inside
* Powerup to change the shape of the opponents hearts so your balls get stuck amongst them easier??
* Make the pause menu render on top of the game
* Make a better sense of control e.g., rotate bat so you can direct your shots better
* Maybe bouncing the ball behind you, risking your lives should have a good benefit for you e.g., powers up the ball somehow??

* Make animated point text
* Power up
    - medical ball to heal lives

* Make it a mobile android game, make it work on LAN if both phones are on the same wifi. Add left and right buttons which light up when the left/right key is pressed (to indicate what this might be like on a phone)

* Separate physics worlds for each player, so you can control time near you only

* Give balls a timer until they explode

* Implement a dedicated server
[] Implement STUN/TURN/ICE. See https://www.twilio.com/docs/stun-turn/faq
* Review the networking/serialization code, make it support a scaled up phyics world better better e.g., with more simulated bodies?

* gravity amongst balls
* Planets for ball?
* Improve graphics
* Flip the view for all players
* Add 3P and 4P options
* Add some powerups
  - Add buttons that can be pressed with the ball to turn on/off some effect
* Add color and player name customization
* Add winning conditions
* Add an option for game mode e.g., best of/first to/rally (high scores)
* Make pausing a quitting the game work better
* Add a restart button
* Options to have the window always on top
* Add Credits
* Track game stats e.g., rally length, near miss count...

* (done) Add text to all the game settings
* (done) Add a basic menu
* (done) Add an option to toggle the ball type
* (done) Add an option to toggle the paddle type
* (done) Add an option to set the level/obstruction type
* (done) Add an option to set the socket address (aka ip_address:port_number)
* (done) Merge with main
* (done) Use local versions of the GetRect and Simp modules

# Payment

* $1.00 purchase cost, get 2 licenses per purchase? to play in 2 player mode. Some fraction to charity? $0.25 per invite after that?
* Database for user accounts etc

# Sound

* (done) Listen to physics contacts
* (done) Play hit sound

# Rendering

* Color the ball based on how it is spinning e.g., CW/CCW
* Fake higher framerates by rendering the sweep of the ball

# Networking

* (done) Make host game choices propogate to clients
* (done) Fix issue where client is initializing box2d
* (done) Send the transform for the level obstructions
* (done) Experiment with how often clients and servers send packets
* (done) Fix crash when client leaves game
* (partial) When disconnecting do we need to flush before we destroy the host?
* @Think WHY do we want to sent input/game state reliably?? (does reliable => acknowledged?)
* @Bug When the client disconnects without notifying the server it does not timeout. Also gets very unresponsive...!
* Reduce the timeout duration on client/server disconnect?
* Use more than one ENet channel.  From the features page: Since ENet will stall delivery of reliable packets to ensure proper sequencing, and consequently any packets of higher sequence number whether reliable or unreliable, in the event the reliable packet's predecessors have not yet arrived, this can introduce latency into the delivery of other packets which may not need to be as strictly ordered with respect to the packet that stalled their delivery.  To combat this latency and reduce the ordering restrictions on packets, ENet provides multiple channels of communication over a given connection. Each channel is independently sequenced, and so the delivery status of a packet in one channel will not stall the delivery of other packets in another channel.
* Implment Snapshot Interpolation. This does physics simulation only on the server, which is good since we don't rely on phyics running on clients (mobile?)
* Use bounding and quantization to send floating point numbers to the clients (we know max velocity of paddle, then we can quanitize that range and send an integer and reverse the process on the client)
* Think about packet size in bytes and how many packets per second we will send (ie determine bandwidth)
* Error checking for port numbers etc
* Aim for latency of 50ms max, 
* Support up to 4 players on differently shaped game boards
* Basic network play
* Get a free invite code when you buy a copy
* How to implement auto updates
* How does alignment affect networking??

    // The size of a struct, measured in bytes of memory, includes enough storage for all
    // its elements, including potential padding between elements. Different platforms
    // may have different alignment requirements. So your struct could end up being different
    // sizes on different target machines, *but*, you are able to query everything about the struct
    // and know these facts at compile time.
    // 
    // Furthermore, you can control padding and alignment manually with compiler directives,
    // which we'll talk about much later in a different file.

# Controls

* (done) Basic mouse control
* (done) Add acceleration to the paddle
* Curve to the ball (applying a force) player motion after the ball was hit
* Add serving the ball?
* Add tilt/rotate button

# Physics

* Make the bindings strip the b2 prefix

iforce2d tutorials suggest I should collect all begin contact events and issue sounds afterwards:

"Collisions between entities in the world will be detected during the b2World::Step() function that we call every time step. As we saw in the topic on worlds, the b2World::Step function advances the simulation, moving all the bodies around and so on. As soon as a collision is detected, the program flow will be given to your callback function to do something, and then goes back to b2World::Step to continue with more processing. It's important to note that since your callback is being called right in the middle of the stepping process, you shouldn't do anything to change the scene right away - there may be more collisions occuring in the same time step." -- https://www.iforce2d.net/b2dtut/collision-callbacks

Use the userdata pointer on the body to point to the game entity so that you can access it in the collision callbacks.  Use an enum in a base class to implement figuring out which entity to cast to

Implement an exploding ball using ray casting in a circle to apply forces to nearby fixtures

Use sensors 

# Gameplay

* (done) Kinematic obstructions in the play area
* (done) Add dome paddle shape
* Remove the box health, that was only needed when we had the healing property of balls your own color, with that removed its probably not needed...
* Portals?
* Ball can have gravitational attraction to the powerups? And the powerups only attach to that specific ball? 
* Get 3 boosts which gradually replenish, its useful to reach for ball when its going really fast
* Make the paddle out of edge elements so you have finer control over the shape
* Maybe there should be an option to play as a the "level/game master" who gets to control the level e.g., how fast things spin etc. Create fun situations where someone can play favourites
* Should be able to launch a ball from your paddle, to make it easier to create the fun situations where you can hit a ball with another ball
* Slow time powerup to temporarily slow down time
* Three balls was really fun (Will playtest)
* Countdown to unpause
* Implement a simple AI
* Sharp corners are bad because its hard to predict what the ball will do when it collides, which feels bad
* Show the short term predicted trajectory of the ball?
* Gradually add the slope to the paddles as you play the game since otherwise you can slam it really hard and win right away
* Gradually change the ball shape as the game progresses, to become more boxy?
* Divide paddles into thirds and have each third have different coeffs of restitution
* Two parallel channels in the level with very high coeff of restitution inside them
* Powerups as goal posts which change the property of the ball
* Powerup to change the shape of the paddle
* Change ball shape e.g., circle, square, elipsoid, hexagon, square with rounded corners?
* Powerup to make the other player smooth so they can't do spin shots. get powerups by
* Add lateral (left/right) boost: if ball bounces during lateral boost add ball spin
* Add vertical/jump (boost): if ball bounces during jump boost increase ball speed
* Experiment with no colliding balls?

# DevX

* Add imgui for debug UI to the project, consider using https://github.com/kevinw/jai-imgui as a starting point for the backend implementation using Window_Creation and Input modules. Then use this to implement debugging for enet in Pong

# Dreams

* Galaga style gameplay but your bullets are simulated balls and need to bounce around amongst the enemies

# Notes
- To hit the ball really fast you can hit it with the side of the paddle, but to do that you need to risk missing the ball entirely which is neat

# Misc

* (done) Add local Player2
* (done) Add text keeping score
* (done) Move player 1 panel left and right
* (done) Switch to MKS units (meters/kilograms/seconds)
* (done) Add ball
* (done) Investigate stream static at ~2h 27min
* (done) Box2D physics for movement and ball
* (done) What kind of Box2D body to use for the player?
* (done) Tweak the scale of things so the physics works well
* (done) Use b2EdgeShape for play edges



# Journal

## 2024/01/25

I have a call with Jimme later, my agenda is roughly:

- Ask him what he's working on
- Ask him about streaming, and if he does that
- Show him the game
  - Mention setting up Azure for a dedicated server
- Show him Prizm

Added a sound effect for when the time warp engages/disengages
Fixed bugs where ball was not deinitted

## 2024/01/26

It was interesting to talk to Jimmy yesterday, he related an interesting anecdote about what he learned from running his own bussinesses: getting potential user attention is critical and difficult, he speculated that much of levelsio success comes from the fact that he managed to get fame from NomadList/early popular products and now finds it easy to find users for his new projects.

He also mentioned the Leisure Suit Larry boss key which I want to look into for the Pong game.

When I pitched the idea I had for distributing Pong as a self updating executable he mentioned he expected Microsoft certification issues. I should look into that, there is some process to get certificed that the exes you distribute are not viruses, and that this can be gamed by competitors who maliciously label your exes as viruses.

Separately. I also read a very long but interesting article on the state of the games industry in 2024, I need to read it again...! Seems promising for smaller developers, and perhaps also for the future of Jai and games made using it and custom engines. https://www.matthewball.vc/all/gaming2024

## 2024/01/29

Spent almost the whole day implementing a function to fit one rect in another preserving the aspect ratios..! Geez, sometimes programming is so hard. Maybe I'm just discovering that games programming is harder than it looks..! 

Felt put out working on Pong at the end of today, it felt like it'll never get fun...


## 2024/01/30

Feeling much more motivated today, spent the morning doing some refactoring which was satisfying. I'm motivated to do the following:

- Make a google doc for game design.
- Send the builds more often to family
- Start tweeting progress
- Make it an android game which you can play over lan by connecting multiple phones to the same wifi


The plan file is better for short term TODOs which I actually do, maybe I should just keep the TODOs in the code so I am more motivated to get rid of them 