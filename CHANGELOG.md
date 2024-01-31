# Version 0.3.0, WIP

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