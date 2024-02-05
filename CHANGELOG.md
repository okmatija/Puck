# Version 0.5.0

* TODO Moved time warp to U and Q
* TODO Added controls menu
* TODO Make explosions affect the paddles to make it harder to aim if someone blows up next to you
* TODO Experiment with lives put on spring but then falling back to the grid shape. This way explosions would look cooler and could have collateral damage

# Version 0.4.0, WIP

* Changed hearts to a row of red boxes (aka "lives") behind each player
* Changed ball colors to match the players, when balls matching your color hit your lives, they heal them rather than inflicting damage
* Changed ball spawning to come from a notch on left/right for player 1/2
* Changed explosion mechanics so explosions occur when ball health reaches zero (balls loose health in high-speed collisions)
* Changed the pause menu so it shows on top of the paused game
* Allowed the paddle move beyond the boundary so its easier to aim balls
* Removed arrow key controls for player one, use JKL instead (later UIO and QWE keys will also be used)
* Added a game over menu rather than automatically exiting to the main menu
* Added auto hiding of the mouse pointer if it doesn't move during game
* Changed single player mode to include an AI opponent. AI skill levels are WIP, Moron does nothing and Mindless/Smart just move left/right
* Updated the logo and tweaked the colors/graphics
* Changed the font from Anonymous Pro to SkyTree by MONTAGNA

I changed my mind on powerups, I think they would make it worse by diluting what the game is intended to be about: precise movements learning about angles/reflections.

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