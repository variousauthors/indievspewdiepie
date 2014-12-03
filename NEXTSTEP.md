- update enemy ships like bullets: ie remove them as they are destroyed and
  iterate their tables backwards

- volleys of missiles

- the grid cells we are using are currently, I think, centered on the
  player. They should instead be a long rectangle away from the player,
  so that the next belt is always actively sending enemies

- player
  + that moves around
  + that can shoot by clicking the mouse
  - that needs to preserve fuel for the long journey
  - that can launch volleys of missiles

- enemies that can collide and kill the player
  + they move to maintain constant distance
  + they explode on contact
  + they shoot the player at a steady rate
    + and predict the player's location
  - that can launch volleys of missiles
  - flocking: they should try not to overlap

- explosions should only last a while
  + bullet explosions do
  - explosion should flash two colours
  - explosion should explode nearby ships
  - ships should break into debris but persist (persistence!)
  - ships should lose some velocity (just add the incident velocity as a force: bullets are low mass, rocks large)

- realistic starfield!
  - adapt the nullprogram algorithm
  - decouple the grid from the stars and the rocks

- level: actually plan out how things are going to go
- a giant space boss
- lerp reticles so that guns turn with mechanical speed
- multiple guns that do different thing (short range chaff gun, long range laser)
  with different rotational speeds
- maneuverable missiles
- camera that lerps and zooms to where the action is
- enemy guns should also have rotation speed, so that you can get behind them
- graphics should be triangles instead of circles, with turrets
  - this will require implementing rotational momentum: thrusting left should rotation your ship left
  - the camera should probably rotate so that you are always facing forward?
- better, more accurate enemies
- variety of enemies
``
- asteroid belts
  + placed like stars, but in belts
  + irregular polygons
  + be able to determine the "active ones" for collision
    + move star generation code into update
    + any rocks off screen should not collide with enemies,
      representing their ability to navigate the asteroids ^o^ (we get this for free because those rocks won't exist)
  + collide with everything
  + some generate enemies
    + only the "next" belt's generators should be active
    + these ones should have a square with one corner on the center of the rock,
      just a green outline with a second square in the center. Then there should
      be a different coloured square that steps slowly in towards the center, counting
      down before the next wing emerges
      + the idea for these enemy factories is from nullprogram's blog
    - it would be nice if they generated enemies into unoccupied space
  - vary the distance between belts
  - disentangle the stars, which are purely decorative, from the asteroids
    - maybe the cells of space should be a whole separate thing, that takes
      callbacks for different purposes (eg, drawing stars vs making rocks)
  - they should rotate gently at different speeds
    - based on up time (so if you leave an come back, rotation is preserved)
  
- forecast the physics and draw a dotted line in the direction a thing
  is going, but also remember where the thing came from and draw that
  dotted line too.
  - limit the length to N steps, and the dost should not move relative
    to the background
  - the object should move along this line like a train along a rail, but
    also the line is dissapearing behind and appearing in front.

- additinoal leaderboards:
  - highspeed: once the top speed is based on the speed of light, we
    can reward the player gets fastest
  - distance: whoever explores the deepest edges of space, closest to
    the king of space

+ highscore system
  + gamejolt api integration
    + this will probably require fixing up main to use the FSM
  + hud to display the score in-game
  + ships killed
  + times score multiplier

+ bullet time
  - "shift" into bullet time?
  + auto bullet time when bullets are near?

+ fix that FUCKING bug with the controls. What even IS that!?
  + push each key event into a buffer and process one key event per button per update

- try going back to nomoon's input events, but with my buffer
