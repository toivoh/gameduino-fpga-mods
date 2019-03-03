Mod: Using the same palette for sprites and tiles to make space for an attribute map
====================================================================================
This patch makes sprites and tiles both read from the sprite palette.
This frees up space to store 4 attribute bits per position in the tile map. (Basically, it's taking over the block RAM that was used by the character palettes; I've made the attribute map accessible at the same range in the memory map that it used as well.)

The reason that this is possible is that the Gameduino actually never needs to read palette data for tiles and sprites in the same cycle, as it alternates between drawing tile background and sprites for each line. Thus, it's enough to add a flag that tells whether we're drawing tiles or sprites, and pass the attribute information along in much the same way as the tile index is handled already. I also replaced the explicit block RAM with an inferred one, to make further modifications easier.

The mod can be seen in action at [https://youtu.be/E278Q4Xh8ck].
