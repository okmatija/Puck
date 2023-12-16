# General

[x] Move player 1 panel left and right
[x] Switch to MKS units (meters/kilograms/seconds)
[x] Add ball 
[x] Investigate stream static at ~2h 27min
[x] Box2D physics for movement and ball
[x] What kind of Box2D body to use for the player?
[x] Tweak the scale of things so the physics works well
[x] Use b2EdgeShape for play edges
[ ] Change ball shape e.g., circle, square, elipsoid
[ ] Add text keeping score
[ ] Add little legs to the paddle, upgrading these makes them bigger chad legs and you can accelerate faster
[ ] Add serving the ball?
[ ] :AddPlayer2
[ ] Network play
[ ] Add tilt/rotate button
[ ] Add lateral (left/right) boost: if ball bounces during lateral boost add ball spin
[ ] Add vertical/jump (boost): if ball bounces during jump boost increase ball speed

# Rendering


# Powerups

[ ] Powerup to make the other player smooth so they can't do spin shots. get powerups by 





















---

Things to report on Jai discord:

[ ] Why does `jai first.jai...` work? adding dots to the end of the file name is allowed? 
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