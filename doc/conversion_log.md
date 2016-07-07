XNA to Godot conversion log
===========================

This is a simple document showing my process of converting the RPG Starter Kit project from XNA to Godot Engine. The idea is to tell what were the struggles to make everything work with a very different engine with almost no paradigm overlap.

Converting the assets
=====================

The first problem to make the game work with Godot was the type of the game assets. The textures were all in PNG format, which make it just a matter of moving them, since Godot can handle those very well. However, the fonts and audio files were a bit problematic

Fonts
-----

The fonts were in BMP format; which Godot can’t understand. Not only that but Godot also don’t have the standard to make images into fonts, at least not with the SpriteFont format used by XNA. Not all hopes are lost though, since the format can be understood with a custom importer.

First I needed to make everything PNG. For that the ImageMagick’s convert tool was perfect. It also kept the transparency of the images, which is an essential property for the conversion. I made the `make_pngs.sh` script for that purpose, so people can see the process and run on their own, since I didn’t save the generated PNGs in the repository as they’re not needed after the conversion.

Then it was time to make use of one of the greatest features of Godot (in my opinion): the ability to build resources via script. So it was just a matter of reading the image data and create a font resource from it. With some bit of work to grab the rectangles from the image and get the characters in the right order, I was able to make a GDScript that reads all the images in the directory and make Godot font resources. The script is on `scripts/convert_fonts.gd` but the font resources were added to the repository in order to don’t break the scenes that depend on them if someone makes a fresh clone.

Font import plugin
------------------

Taking leverage of the plugin system from Godot 2.1, I decided to make an importer plugin for SpriteFonts. This was mostly done for a proof of concept but it can be shared for people who kept old SpriteFont textures around and want to use Godot.

Relying on the demo importer plugin, it was a straight to process to make it work as intended. The only problem I found is when editing the textures and characters of a font being used in the editor can cause some issues. Then I got the answer in the development IRC channel that I just needed to emit the `changed` signal so the render engine would be aware of the changes. With that, the plugin could then import and re-import SpriteFonts.

This plugin is available under the `addons/spritefont_importer` folder. It is very basic and there’s room for some extra options. For this project the command script is still better because it just batch convert everything needed but the plugin also works perfectly.

Audio
=====

While XNA used the Wave format for everything, Godot uses them only for samples. This is good for sound effects, since they’re short and don’t have much time to decode. For background music, though, it’s better to use a compressed format, and Godot don’t allow Wave format for those.

So I needed to convert them. Again another third-party tool is good for the job: ffmpeg. I made script `make_audio.sh` to convert the audio files to Opus format. But since in the original project kept them all in the same directory, I used the suffix of the file name to decide what would be a sound effect (and them be copied as Wave) and what would be background music (and converted to Opus to use as streams). Since the BGM files ended in `Theme.wav`, this was possible to automate.

While `LoseTheme.wav` and `WinTheme.wav` can be used as streams, I thought for a moment to make them samples, since they’re short and one-off. However, the files were too big for my taste and those themes weren’t played in critical places to be synchronized so there wasn’t a need to keep them as samples.

Also, since the XNA SoundManager is responsible for everything and doesn’t differentiate streams from samples, this might require some logic to convert. But that’ll be done later.

The main menu screen
====================

Starting at the start, I decided to translate the main menu screen to Godot. This was very interesting since in the XNA game the positions are calculated based on some hardcoded values and plus the size of textures and texts.

With a little bit of understanding all the math involved, I was able to make it into a Godot scene using only the visual editor. Well except for…

The menu itself
---------------

The way the menu buttons are laid-out, a `VBoxContainer` seemed the best way to go. The hard part was to make sure every button was in the right place.

After undoing the math to make it all in the hardcoded place from the start (since Godot editor is very visual) the container got the right properties. The most relevant ones are the Alignment (since the buttons are positioned based on the last one, so it grows upward when the Save Game button is added), the Position and the Minimum Size (which must be set to make the buttons be in the lower end from the start).

Then it was just a matter of making the buttons. Putting the six buttons was trivial and just a matter of making custom style boxes for the textures, selecting the proper font and colors. I also made a script for the buttons to get colored when focused, not only when hovering the mouse (in fact, the mouse can’t be used at all, as in the original game). I added a little bit of logic to mimic the effect of losing focus when the window lose focus. This script also is responsible for emitting a signal when focused sending a description string that can be set on the Inspector. Note that this same script is added to every button.

A problem that I bumped into was that every button has a different horizontal offset, but the container insists and putting them all at the same horizontal position. So I edited the button script to add an exported position offset variable and make sure that it was set as left margin every frame, so when updated (e.g. when the Save Game button changes visibility) the margin is not sent back to zero by the container. This is the most hackish code so far (while the buttons’ focus color is a bit hackish, it is mostly an extension of the engine and I can wait for signals to set those).

Just note that buttons do not have any navigation hints by default, so I had to set the top and bottom neighbors of each one. After that the standard UI controls can be used to navigate and it just works, which is very nice.

Even with that nuisance with the horizontal offset, positioning and centering stuff in the editor is much more natural than doing math in the code.

Project settings
----------------

I had already changed the resolution of the game to match the original (1280x720 pixels). I just noticed that the images become somewhat blurry, so I disabled filter and mipmaps, which made them sharp again.

This also made me notice that the fonts on Godot are sharper. Maybe the XNA game have some half pixels cause by the positioning math. I probably could mimic that too to make it look exactly the same, but there is no point in doing so.

The Message Box
---------------

Laying out the message box was again a matter of rewinding the math and adjust the controls’ margins. Here though I need to make a little compromise: the original message box centered the message position, but left-aligned it when there were multiple lines. In Godot I could only perfect align with one or the other, so I chose to show the message centered even if it meant being a little different. I also need to put a negative value under the line-spacing property of the label to make the message be more alike the original.

At first I was wondering how to dark the background without a texture, but it turned out that the XNA version also used a texture. So it was just a matter of making a `PopupPanel` and setting the panel style box to such texture.

Then I needed to make it steal the focus to avoid letting it on the button, because then the user could interact with buttons while the message was showing. `PopupPanel`s don’t receive focus by default and the property can only be changed via code. A simple call to `set_focus_mode(FOCUS_ALL)` in the `_ready()` method was enough to fix this.

With that ready, I could then just override the `_input_event(event)` virtual method to send signals on confirmation and cancel. I prefer to use signals so this scene can be reused to do multiple things and the instance can define the behavior.

Then I used the `_unhandled_input(event)` virtual method on the main menu scene to show the exit message box. Since it’s a texture frame, it has no natural way to handle the input without stealing the focus. This was very straightforward and the result feels much faster than the original XNA game.

UI Input Mapping
----------------

There’s a bit of problem with the default input map actions because they weren’t really what I wanted. I tried to work around that to avoid them completely, but changing focus and sending pressing events by custom code is not very nice.

In another IRC chat someone gave me the idea to replace the default keys. The default actions cannot be removed but they are saved If you change the keys, so this turned out to be the easiest and simpler way to deal with the UI.

The help screen
---------------

Since the screens for help, controls and save/load have some common elements, I decided to make a base content screen and use scene inheritance to add screen specific elements.

As with the others, positioning stuff was straightforward. The most work was to make the scrollable text. However, Godot already had the feature under the Label node: the properties for max lines visible and skipped lines. With a little bit of scripting it was easy to make the scrollable label.

I noticed that the up and down arrows don’t change in any way. While I could see an improvement here, my goal is to just replicate the game as it is.

The controls screen
-------------------

This required a little bit of work. The scroll system was ripped off from the help screen, since I used labels for this. There is no built-in control to make this easier, but it was straightforward to make.

A problem I hit here is that Godot doesn’t differentiate modifier keys by position, so left Shift is the same as right Shift. With the power of open source, this might be fixed before I finished the project, then I’ll change this to work as the original.

I had to hard-code the list of actions. While I can grab those from `InputMap`, I needed the descriptions and to keep a certain order. At least the name of the keys can be taken from there, avoiding more redundancy.

Other screens
-------------

For load and save screens just a simple screen with a label. There’s no save/load mechanism yet, so I decided to postpone this screen and do it all at once later.

The load screen for new game is also a mock. It just overlays the main menu. The proper loading function will be added later.
