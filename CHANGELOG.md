When releasing a new version remember to add a git tag...!

# Version 0.5.0

* Added limit to time warping and made it gradually recharge when unused
* Added visualization showing remaining amount of time warping
* Explosions now damage lives and apply impulses to balls within their radius
* Fixed cases when the aiming lasers rendered but the ball would not actually collide with the paddle
* Added jai compiler version text, to help with building old versions for posterity
* TODO Add a countdown to start the game
* TODO Moved time warp to U and Q
* TODO Added controls menu
* TODO Make explosions affect the paddles to make it harder to aim if someone blows up next to you
* TODO Experiment with lives put on spring but then falling back to the grid shape. This way explosions would look cooler and could have collateral damage

# Version 0.4.0, 05 February 2024

* Changed hearts to a row of red boxes (aka "lives") behind each player
* Changed ball colors to match the players, when balls matching your color hit your lives, they heal them rather than inflicting damage
* Changed ball spawning to come from a notch on left/right for player 1/2
* Changed explosion mechanics so explosions occur when ball health reaches zero (balls loose health in high-speed collisions)
* Changed the pause menu so it shows on top of the paused game
* Added some features to make it easier to aim the balls:
  - Added line segments showing future ball trajectories. This only works on balls of your own color
  - Allow the paddles to move beyond the boundary
* Removed arrow key controls for player one, use JKL instead (later UIO and QWE keys will also be used)
* Added a game over menu rather than automatically exiting to the main menu
* Added auto hiding of the mouse pointer if it doesn't move during game
* Changed single player mode to include an AI opponent. AI skill levels are WIP, Moron does nothing and Mindless/Smart just move left/right
* Added ability to speed up time in single player mode, this will eventually also be used in multiplayer mode when there are separate physics worlds for each player.
* Removed the ball shape and paddle shape options. These were just developer options and not particularly fun to edit.
* Updated the logo and tweaked the colors/graphics
* Changed the font from Anonymous Pro to SkyTree by MONTAGNA
* Changed the implementation of the dome shaped paddle to use an exact circle profile for physics, rather than a piecewise flat polyline

I changed my mind on powerups, I think they would make it worse by diluting what the game is intended to be about: precise movements learning about angles/reflections.

Maybe square balls count be brought back if we use a physics simulation to determine the future ball trajectory, I experimented with a simulation approch for the future ball trajectories but circle casting is simpler/faster and works well for circles.hmm...

# Version 0.3.0, 31 January 2024

* Replaced text scores with hearts/lives behind the players
* Win the game by destroying all the opponents hearts!
* Increased maximum number of balls to 4
* Balls exploded on (non-player) collisions if they are move fast enough
* Fixed networking (many WIP things are not replicated on the client yet)
* Added a SFX volume control to the Settings menu

# Version 0.2.1, 30 January 2024

* Workaround the crash in 0.2.0 (hopefully???)

# Version 0.2.0, 30 January 2024

* Added a single player mode (but I broke networked multiplayer, opps)
* Implementation of powerups v1 (WIP):
  - Ball colors are set to the color of the last player that hit them
  - Ball colors are passed on via collisions: the color of the faster ball is propogated
  - Powerups are obtained by hitting them with a player colored ball
  - The grey boxes will become powerups, maybe you have to hit then N times, or fast so they smash...?
* Changed the shape of the play area
* Changed the shape of obstructions
* Changed the position of the scores
* Changed the menu background---don't use unmodified AI art
* Improved ball spawn behaviour