Dreamfall Chapters: The Final Cut
=================================

Shaderhacker Lore Chapter One: The Unity Lighting Breakthrough
--------------------------------------------------------------
This title represents something quite special to this community, because this
fix is not just about this one game - you've seen my Unity templates credited
over and over on so many fixes, and the work I have put into this one game
really represents all of those fixes combined.

Those of you who have been here for the last few years might recognise that this
isn't the first time I've fixed this game, nor is it even the second or third,
and each time have I worked on this game we have made leaps and bounds forwards,
and this update is no different.

The first time I fixed this game back in 2014 was when [I cracked the
"unfixable" Unity lighting pattern wide open][1], and developed the maths and
techniques that would be right at the centre of just about every Unity fix that
has been released since then. Prior to this Unity games could only be
approximately fixed if the FOV never changed.

[1]: https://forums.geforce.com/default/topic/781954/3d-vision/dreamfall-chapters/post/4349583/#4349583

Shaderhacker Lore Chapter Two: Templates and Scripting
------------------------------------------------------
Since this game was episodic it meant I had to update the fix each time a new
episode was released, and the first few updates were mostly uneventful, with
just new scenes added to the game that I had to go in and fix. In the time that
had passed before these updates I had turned my lighting fix into a template and
scripted some of the more common patterns, allowing me to fix these early
updates in a matter of days or hours, instead of the three and a half weeks that
it had taken for the initial fix.

Shaderhacker Lore Chapter Three: The Reflection Breakthrough and Automatic HUD
------------------------------------------------------------------------------
When this game switched to Unity 5 and I had to restart the fix entirely from
scratch I spent some time trying to make the reflections and specular highlights
more pleasing in 3D, and I [succeeded beyond my wildest expectations][2] - I
didn't just fix the obvious reflections like puddles and glass - I managed to
fix *everything*, adding small details to almost every object, popping building
interiors into 3D, adding moisture to Zoe's lips and sparkles in her eyes, and
even making materials like leather, wood and stone reflect light in just the
right way to look realistic. In other games like The Forest this has even
managed to pop flat sand and rock textures into detailed three dimensional
surfaces, and the same approach to fixing specular highlights has worked in
other games that don't even use Unity, like Metal Gear Solid V, Far Cry Primal
and WATCH_DOGS2.

To make these reflections work with the limitations of Helix Mod I also had to
fundamentally rework my Unity lighting fix, making this the second time I had
used this game to invent a new Unity lighting fix, and every physically accurate
reflection and specular highlight you see in a Unity game since then is because
of this.

[2]: https://forums.geforce.com/default/topic/902840/3d-vision/i-fixed-unity-reflections-and-got-more-than-i-bargained-for/

For that update I had dug into some relatively obscure features of Helix Mod and
was able to figure out how to use them in combination with my own automatic
crosshair technique to adjust the HUD depth so that it would [follow the
location of the floating HUD icons][3] automatically, but at the time I was
still stuck with a 2D mouse cursor and some other limitations of Helix Mod.

[3]: https://forums.geforce.com/default/topic/902840/3d-vision/i-fixed-unity-reflections-and-got-more-than-i-bargained-for/post/4754023/#4754023

Shaderhacker Lore Chapter Four: The End?
----------------------------------------
I had to re-fix the game entirely from scratch one more time for the Unity 5.3
update (which is a [whole other article][4] in itself), but finally Book 5 was
out and the game was finally complete, end of story...

[4]: https://forums.geforce.com/default/topic/933594/unity-5-3-scripts/

Shaderhacker Lore: Interlude
----------------------------
...or at least it was, until the developers decided to switch to DirectX 11 in
preparation for The Final Cut, completely breaking my fix once again :-(

Unfortunately as some of you [might already be aware][5] I had been forced to
check out from this community and leave my day job to deal with a major (and
ongoing) mental health crisis brought on by a combination of factors including a
series of very bizarre coincidences in my personal life, and I have only
recently mustered up the strength to try to return to this community and start
modding games once again.

But I couldn't just leave this game in a broken state when my fix had meant so
much to me personally and this community more generally - that would be like an
artist having their prize work stolen from them (is it surprising that so many
modders in so many communities burn out?). This fix was a showcase for my
talent - like the kind of thing you might display in a portfolio, and something
I very much did when networking with other local game developers.

[5]: https://forums.geforce.com/default/topic/1000942/3d-vision/where-has-darkstarsword-been-/

Shaderhacker Lore Chapter Five: DirectX 11, 3DMigoto and The Final Cut
----------------------------------------------------------------------
I took the change to DirectX 11 as an opportunity - I had already adapted my
Unity template to work with DX11 and 3DMigoto for previous games, but this game
is far more complicated for all sorts of reasons and needed so much more work to
be done. This fix is released alongside [3DMigoto 1.2.65][6] - with thousands of
new lines of code, dozens of new features and a month and a half of pretty much
full time (because unemployed because depression) development work this is the
largest single update to 3DMigoto in the entire 1.2.x series. This release adds
a whole new ini parser that allows this fix to load in under one second instead
of the two minutes that it would have taken with the old parser. It adds a
software mouse cursor implementation - so at long last the mouse cursor depth
can follow the rest of my automatic HUD adjustment (plus, this will work with
the SBS/TB output modes of 3DMigoto), and [countless other new features][6]
that were needed for this game as well. I have also made some major updates to
my Unity scripts and template, to not only work with some quirks of this game,
but also to increase performance by a whopping 10-20fps!

[6]: https://forums.geforce.com/default/topic/685657/3d-vision/3dmigoto-now-open-source-/post/5213770/#5213770

Those of you who have used a few of my fixes will know that I pride myself on
being able to make almost any effect work in stereo 3D - I'm very good at
figuring out complex problems and it is extremely rare for me to just outright
disable an effect that doesn't work in 3D. This game however, uses volumetric
ray-marched light shafts in a lot of the interior light shafts and after
spending several weeks on these back in the day I had to admit defeat when I
realised that they were going to be impossible to fix with the limitations of
Helix Mod. These were the only light shafts that have ever eluded me, and with
the switch to 3DMigoto I took the opportunity to have another crack at these,
and while they were still *extremely difficult* I managed to pull it off, and
the effect is really quite stunning:

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/bIIBMT3_wS4" frameborder="0" allowfullscreen></iframe>
</center>

The automatic HUD adjustment for this game is back as well, only this time the
flexibility that 3DMigoto and DirectX 11 allow means that it is even more
sophisticated than before - it now analyses every active HUD element to decide
what depth to render the HUD and mouse cursor in each frame, and can take into
account transparent objects such as glass monitors to render the HUD on top of
them.

SKIP! SKIP! SKIP! Too much lore! What did you fix already?!?
------------------------------------------------------------
If you couldn't get through all the lore above beware that this might not be the
game for you as it is pretty lore heavy in itself. Although personally, the
thing that appeals to me the most about The Longest Journey and the two
Dreamfall games is that the main characters from Stark are just ordinary people
that talk about ordinary things like life and relationships and have been thrown
into events beyond their control... and of course Crow, the best comic relief
sidekick in any game ever.

- Major updates in [3DMigoto 1.2.65][6] for this game
- Major updates to Unity template for higher fps and to handle certain cutscenes
- Lighting / Shadows
- Halos
- Volumetric Light Shafts (the bane of my existence has finally been defeated)
- Physically Accurate Reflections / Specular Highlights
- Screen Space Reflections
- Ambient Occlusion
- Parallax Building Interiors
- Sun moved to infinity
- Replaced the hardware mouse cursor with a software mouse cursor
- Automatic HUD and mouse depth adjustment that follows the icons on screen
- Separate automatic subtitle depth adjustment
- The HUD depth is fixed whenever the inventory is open to line up with it
- Automatic low convergence + mouse depth preset when picking up an item or
  examining it in the inventory
- The Purple Mountains background being at closer depth than the foreground is
  fixed compared to the old version, but I can't take credit for that - the
  developers finally stopped rendering two separate scenes in the same 3D space
  ;-)

Installation
------------
1.  Extract the contents of the zip file to the game directory.

2.  If you are running the 32bit version of the game, replace the DLLS with the
    ones in the 32bit directory.

3.  - Right click on the game in Steam and go to "Properties" -> "Set Launch
      Options" and enter "-window-mode exclusive" (without the quotes) and click
      "Ok"
    - If you are not using the steam version, launch the game with the provided
      "Dreamfall Chapters - 3DMigoto.bat"

4.  If 3D Vision didn't kick in, make sure that full screen is enabled in the
    game settings.

5.  If 3D Vision still didn't kick in, you may have to alt+tab out and back, or
    try pressing alt+enter twice.

Notes
-----
The Volumetric Light Shafts can be pretty expensive in 3D. In most places they
are used in this game they aren't too bad, but they can really tank performance
in The Hand That Feeds which has five large light shafts filling most of the
room (the developers even turned off the dynamic real time light shaft shadows
in that room to save on performance, but it still tanks), so you may need to
lower their quality slightly in the settings menu if you find the framerate too
low in that room (I just put up with it - the highest quality light shafts are
worth it elsewhere in the game, especially the ones that have real time shadows
enabled). If you are playing on an underspec machine and finding that these hurt
performance too much even on the lowest quality setting you can disable these by
searching for [CommandList_Volumetric_Light_Shafts_Common] in the d3dx.ini and
uncommenting the handling=skip line below it.

The subtitle depth adjustment is capped so that they can't pop too far out of
the screen. This limit can be adjusted by editing the d3dx.ini and adjusting the
x value under [Constants]

Side-by-Side / Top-and-Bottom Output Modes
------------------------------------------
This fix is bundled with the new SBS / TAB output mode support in 3DMigoto. To
enable it, edit the d3dx.ini, find the [Present] section and uncomment (remove
the semicolon) the line that reads:

    run = CustomShader3DVision2SBS

Then, in game press F11 to cycle output modes. If using 3D TV Play, set the
nvidia control panel to output checkerboard to remove the 720p limitation.

Like my Work?
-------------
As you would have gathered from reading the lore, fixing this one game has taken
an enormous amount of my time - Steam shows I've spent close to three hundred
hours with it running (probably a hundred of those would have been spent staring
at those light shafts alone) and all up I can say that I would have probably
spent about three months or so working on this one game - not counting time
focussing on other games that went towards working on the Unity template,
scripts and many of the features I've added to 3DMigoto over the years that
this builds on.

I'm also currently out of a job largely thanks to my ongoing battle with mental
health issues, and until I have recovered enough to work on changing that I am
entirely dependent on my wife for support, and any donations I receive from this
community. I hope you can see that even if you are not interested in this
specific game, that the work I have put into it goes far beyond this one title.

I usually prefer not to say much when I post this donation link - because no one
likes begging, but given the significance of this fix I felt it prudent to go
into more detail and share a little of my [personal situation][5].

If (and only if) you feel that you are in a position where you are able to do
so, please consider [supporting me with a monthly donation on Patreon][7], and
thanks again to those that already do! While I prefer the more stable monthly
support that Patreon offers, I can of course understand that some of you prefer
to make one-off donations when you can, and for that you can use [my
Paypal][8]. As a reminder, these donations are to support me personally, and do
not go to other modders on this site.

[7]: https://www.patreon.com/DarkStarSword
[8]: https://www.paypal.me/DarkStarSword

_This mod is created with 3DMigoto (primarily written by myself, Bo3b and
Chiri), and uses Flugan's Assembler. See [here][9] for a full list of
contributors to 3DMigoto_

[9]: https://darkstarsword.net/3Dmigoto-stats/authors.html

I also have to thank mike_ar69, 4everAwake and Bo3b who helped me in the early
days while I was learning ShaderHacking, and while I was starting out looking at
Unity in particular.
