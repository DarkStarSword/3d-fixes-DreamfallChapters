Dreamfall Chapters (All Books)
==============================

Update 2017-nn-nn
-----------------
- Re-fixed game from scratch (again!) for the The Final Cut / DX11 and Unity
  5.4 updates

**NOTE: The old DX9 version of the fix should be removed before installing this one**

**NOTE: The installation instructions have been updated**

Update 2016-06-20
-----------------
- Re-fixed game from scratch (again!) for the Unity 5.3 update

- Fixed Book 5

Update 2015-12-10
-----------------
This is a major update:

- Re-fixed game from scratch for the Unity 5 update

- Fixed Book 4

- Added an automatic depth adjustment to the HUD. The floating targeting icon
  and descriptive text will automatically adjust their depth to match whatever
  the icon is resting on. This is not 100% perfect (and the mouse cursor is
  still at screen depth), so it can be toggled on and off with Q.  
  [Info about the technique][1]

[1]: https://forums.geforce.com/default/topic/902840/3d-vision/i-fixed-unity-reflections-and-got-more-than-i-bargained-for/post/4754023/#4754023

- Brand new Unity lighting fix (yes, this is the second time this game has been
  used to develop a new lighting fix) - looks exactly the same as the old one,
  but it was necessary to work within some constraints in Helix Mod to also
  allow:

- Brand new Unity reflection fix. Aside from the obvious things like windows,
  glass, water, puddles, and even Zoe's eyes, this also adds a lot of small
  detail to many objects (literally thousands of shaders were adjusted to fully
  enable this). With Unity 5's physically accurate lighting model this makes
  the way light hits certain surfaces appear more realistic - hair has more
  detail, highlights reflecting on wooden surfaces are below the surface, and
  even things like Zoe's leather jacket reflect light in just the right way. I
  highly recommend loading a save from Book one and taking a stroll around
  Propast to see the difference this makes :)  
  [Screenshots and info about the technique][2]

[2]: https://forums.geforce.com/default/topic/902840/3d-vision/i-fixed-unity-reflections-and-got-more-than-i-bargained-for/

Installation
------------
1. Extract the contents of the zip file to the game directory.

2. If you are running the 32bit version of the game (the GOG version recently
   switched to 32bit, and Steam will install the 32bit version if your OS is
   32bit), replace the DLLS with the ones in the 32bit directory.

3. - Right click on the game in Steam -> Properties -> Set Launch Options ->
     enter "-window-mode exclusive" (without the quotes) and click "Ok"
   - If you are not using the steam version, launch the game with the provided
     "Dreamfall Chapters - 3DMigoto.bat"

4. If the game doesn't start with 3D Vision activated and you have followed
   step 3 and the in game settings have full screen enabled, you may have to
   alt+tab out and back, or try pressing alt+enter twice.

Fixed
-----
- Lighting and shadows

- Physically accurate reflections

- Glow around lights

- Halos on all surfaces

- Automatic HUD depth (toggle with Q)

Known Issues
------------
- Volumetric ray-marched light shafts are at screen depth and are disabled. You
  can re-enable them with U.

- The mouse cursor depth is not adjustable as it uses a hardware cursor.

- The Purple Mountains background is drawn closer than some of the foreground.
  This is not a skybox - it is in fact two scenes rendered on top of each other
  making it difficult to separate them.

Additional Notes
----------------
- I have not replayed the entire game since the Unity 5.4 update. If you find
  something broken (especially things like glass or heat distortions), please
  let me know.


Thanks to everyone who helped out on the forum to make the original Book 1 fix
possible, especially 4everAwake and mike_ar69! This was the game where we
cracked Unity 5 lighting and has enabled many more fixes since - shaderhackers
may be interested in reading through [this thread][3] for background on the
original technique.

[3]: https://forums.geforce.com/default/topic/781954/3d-vision/dreamfall-chapters

Like my Work?
-------------
Consider supporting me on [Patreon](https://www.patreon.com/DarkStarSword)
