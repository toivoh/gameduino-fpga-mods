Mod: Tile flip/rotation attributes
==================================
This mod allows to use on or more of a tile's top 3 attribute bits to specify tile flipping/rotation instead of palette selection (tile attributes were added in the [tile attribute map mod](../tile_attr_map/)).

The mod adds 3 new bits to the `PALROT_MASK` register (`0x28c2`, previously called `SPR_PALROT_MASK`):
- bit 5: When cleared, use attribute bit 5 for diagonal tile flipping
- bit 6: When cleared, use attribute bit 6 for vertical tile flipping
- bit 7: When cleared, use attribute bit 7 for horizontal tile flipping

When an attribute bit is used for tile flipping, it will act as if it were zero for palette selection.
Tiles in text color mode never use the attribute bits for flipping (see the [text colors mod](../text_colors/)).

The flip bits combine in the same way as they do for sprites, but the order of the horizontal and vertical flip bits has been interchanged.
It is expected that horizontal flipping will be used the most often, and diagonal flipping the least often; this order keeps the palette bits together in what is expected to be the most common cases.

A short demonstration video can be found at https://youtu.be/1LaAo3kDsCQ

The source code in this mod is based on the source for the [blending mod](../blending/) (there's an option to disable the blending feature if this mod is desired without the blending).
