# Godot's XNA RPG

A port of the [XNA 4.0 RPG Starter Kit](http://xbox.create.msdn.com/en-US/education/catalog/sample/roleplaying_game)
sample game to [Godot Engine](https://godotengine.org).

## About

This is mostly a proof of concept to show the capabilities of Godot and how work
can be made more easy using the built-in features (e.g. tile sets, sprite sheets, etc.).

The idea is to use the original assets, including the XML data for some of
the content (like quests) and convert the ones that are not needed, such as
maps and characters, leveraging of the inner power of Godot.

The code will be translated to GDScript where it applies (combat AI, movement
logic, etc.) and simply discard otherwise (tile engine, rendering, etc.).

## Running

To run the project you need the latest Godot Engine binary. Run it with
`godot -path project`. Releases will be provided after a significant amount of
work is done.

Running the original game reqquires you to build it. There'll be a built release
available to download at the [releases section](https://github.com/vnen/xna-rpg-godot/releases).
For that you need just to unpack somewhere and run it. You might need to install
the [XNA Framework Redistributable](https://www.microsoft.com/en-us/download/details.aspx?id=20914).

To build the original game requires the XNA framework 4.0. Since it's not available
on recent Windows versions, you can try to install it following the steps [on this blog post](https://blogs.msdn.microsoft.com/astebner/2009/06/12/steps-to-install-xna-game-studio-without-using-the-setup-bootstrapper/),
which bypass the bootstrapper and then allows it to be installed on Windows newer than Seven.
You can also use [MXA](https://mxa.codeplex.com/) instead, though that don't come with XNA Live Proxy,
so you'll have to remove the `GamerServicesComponent`.

It may or may not work with [MonoGame](http://www.monogame.net/]).

## License

The work here is under the [MIT License](LICENSE). The original work and the
converted assets remain under [Microsoft Permissive License Ms-PL](original/LICENSE.md).
