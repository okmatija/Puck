[x] Move player 1 panel left and right
[x] Switch to MKS units (meters/kilograms/seconds)
[x] Add ball 
[x] Investigate stream static at ~2h 27min
[ ] :Physics Box2D physics for movement and ball
[ ] Change ball shape e.g., circle, square, elipsoid
[ ] Add serving the ball?
[ ] :AddPlayer2
[ ] Network play
[ ] Add tilt/rotate button
[ ] Add lateral (left/right) boost: if ball bounces during lateral boost add ball spin
[ ] Add vertical/jump (boost): if ball bounces during jump boost increase ball speed























---

Things to report on Jai discord:

[ ] Why does `jai first.jai...` work? adding dots to the end of the file name is allowed? 


---

Notes from frame-rate-independence talk

- have framerate be really high and consistent so that you minimize problems related to reading player input at slow/variable dts, which leads to the game feeling bad
- Use exact evaluation when possible so you can make sim(sim(state_0, dt), dt) == sim(state_0, 2dt)

Box2D notes:

// use MKS units (meter-kilogram-second)
// handle tunneling by finding first time of impact (TOI), then sub-step to that time and then resolve the collision
