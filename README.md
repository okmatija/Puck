# Puck

An unfinished multiplayer airhockey game.

<p float="left">
  <img src="data/menu_0.5.0.png.png" width="45%" />
  <img src="data/game_0.5.0.png.png" width="45%" />
</p>

# Feedback

For the latest version (0.5.0) I got some good feedback about how the game could be improved. Here are my responses.

> I didn't know what was happening with the lasers (are they just reference?)

Each frame the balls in your half are shape cast along their current trajectory and if they collide with your paddle the laser is rendered. It shows the path the ball will follow if you don't move your paddle and if the ball does not collide with another ball.

The problem this is intended to solve is to help you aim at a specific box on the opponents side, the circle segment shaped paddles make it possible to choose the outgoing direction of the balls that collide with you but unless you render the trajectory its hard to use this to aim properly. Actually I originally had a system where each frame I would simulate the game 2 seconds into the future assuming your paddle didn't move and then render lasers for the paths of each ball. This was cool because you could see all the trajectories. I replaced it with the current simpler system which assumes no ball-ball collisions because I thought it would be more interesting to have to anticipate those collisions, the simulation also looked weird for really slow moving balls that don't go far in 2 seconds.

> I wasn't sure why the balls would sometimes explode...

If the balls move fast enough then they take damage in collisions. The problem this is intended to solve is remove balls which are moving so fast you can't react to or even see them. I was thinking that with some improvements to the damage system and graphics this could be made clearer e.g., balls absorb energy in every collision and when they reach a certain energy level they explode. The explosions serve another purpose too: I noted that when the opponent has only one box left they can just sit in front of it and make it so you have destroy they box from behind. I thought having exploding balls can mean that even if you block your boxes like this they can still be destroyed if the ball explodes on colliding with your paddle. That said maybe all this is too complicated, I could just make them explode the first time they collide while moving too fast (usually this happens after you hit it sideways with your paddle so it doesn't counter the the blocking-your-last-life strategy, perhaps it works with your air-hockey suggestion though...)

> ...or what was causing new balls to appear.

When a ball explodes a new one appears after some countdown expires. Again, I thought I could make this clearer with better graphics e.g., a new ball is shown at the notch in the middle of the game area and slowly slides into the game.

> spinning center -- it feels very chaotic

Yes, you are right.  The idea was to make it path of the balls more interesting, but perhaps ball-ball collisions make it interesting enough. Its also a bit confusing with how to deal with obstructions that cross between worlds with potentially different time steps


> It felt hard to think about the game in terms of aiming or strategy; with the amount happening

Yes. I wanted the game to be about aiming and incoming/outgoing trajectories in circle-circle/circle-plane collisions.  I should think of a way to focus on that

> with so much happening it was hard to notice my successes and failures

This is a very interesting point, I had not thought of that, thanks for the link!

>The physics engine-ness of the game feels more like air hockey than pong; I wonder if on mobile especially it'd be more fun if you had a circular paddle that could move a bit forward and back rather than just side to side.

Yes, I think your right, I hadn't anticipated how it would feel to tweak physics-based gameplay, you can only control it implicitly and its quite fiddly, it gives me a renewed appreciation of fall guys for sure! Air hockey is an interesting idea,  I had implemented controlling the paddle with the mouse and that helps with finer positioning but I thought it felt weird having the paddle catching up to where your mouse was (limited speed is important to not make balls shoot off super fast all the time). Maybe it didn't feel that bad though. I wonder if moving a disk around with your finger would obscure things you want to see, with only left/right motion I could make it so you swipe left right below where the paddle is and you only need a small strip of screenspace reserved for it. But it could be that the pros out-weight these cons though.

> Fwiw my instinct if I were trying to design my own take on pong would probably be to identify one thing that I want to change in the game, while keeping the rest of the game very close to the classic experience.

Hmm, yes perhaps I should do that, a common theme in your feedback was that things are too complicated, and I definitely agree! Thanks for the foddy link as well, he seems like a good person to learn from

> if the title is 'ok pong' then players may expect it to be closer to classic pong.

This is a working title, I have not thought of a name yet. The code directory is  Pong/ because its inspired by pong but thats the only reason. The 'ok' part comes from my twitch/github username being okmatija. I made a logo quick to replace some midjourney art I used but I think I won't use any AI art in the end, and I was thinking a neon art style would be doable as a programmer with minimal art skillz.