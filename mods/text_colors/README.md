Mod: Text colors
================
This mod is built on the [tile attribute map mod](../tile_attr_map/v2). It provides a way to make some tile ids behave as text characters, where
- the attribute byte can be used to select between 16 different foreground colors and 16 (possibly different) background colors, and
- two 1 bpp tile bitmaps are stored in the same 2 bpp tile graphic.

The mod doesn't really make anything possible that wasn't possible before, but it allows to use (colored) text while consuming less graphics memory and much fewer palette entries.

New registers:
- `CHR_TEXT_MODE_MASK (0x28c4)`: tile index bits `[8:6]` (out of `[9:0]`) are used as an index into `CHR_TEXT_MODE_MASK` to see if the tile is in text color mode
- `CHR_PALBASE_FG (0x28d4)`: The 16 color text foreground color palette starts at index `CHR_PALBASE_FG*4` in the palette
- `CHR_PALBASE_BG (0x28d5)`: The 16 color text background color palette starts at index `CHR_PALBASE_BG*4` in the palette
- `SPR_PALBASE_256 (0x28d3)`: The 256 color sprite palettes start at index `SPR_PALBASE_256*4`. (This register came as a bonus with a new implementation of palette base registers.)

If `CHR_TEXT_MODE_MASK` indicates that a tile is in text color mode,
- The low or high bit is used from the current pixel value, depending on the 10th bit of the tile index
- The attribute byte is taken as bbbbffff = pppppppp, and depending on the pixel bit, one the following to colors is used:

        foreground_color = (ffff) + CHR_PALBASE_FG*4
        background_color = (bbbb) + CHR_PALBASE_BG*4

Otherwise, the tile is treated as in the previous mod.

The text color feature is mostly useful in attribute mode (see the [tile attribute map mod](../tile_attr_map/v2)). To use it, set some bits in `CHR_TEXT_MODE_MASK` to enable text color mode for some tile ids. Bit 0 controls tile ids 0-63, bit 1 ids 64-127, etc.

To set the two extra tile id bits, write them into `NINTH_WRITE (0x28c9)`, and then write the tile id byte followed by the attribute byte to the tile map. (For more about ninth bits, see [512 tiles mod](../512_tiles/))

The mod can be seen in action at https://youtu.be/uFLW1hp1pBA

The mod makes a new implementation of the palette base registers `SPR_PALBASE_4`, `SPR_PALBASE_16`, etc, (first introduced in the [sprite palettes mod](../sprite_palettes/)). Instead of flip flops, they are now stored in a small distributed RAM. This not only saves logic resources, but makes up to 16 different palette base registers available at almost no additional cost. With the current mod, a total of 6 of these are used.
