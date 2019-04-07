Mod: Tile map with interleaved attributes
=========================================
The original Gameduino has space for 1024 palette colors for tiles (and 1024 for sprites), but each of the 256 graphic tiles is tied to its own 4 color palette. This mod adds a mode with two bytes per tile map entry; enough to specify both a tile index and a palette independently (and to choose between more tiles as well).

Apart from the new attribute mode (with two bytes per tile map entry), the mod
- changes `RAM_PAL` from storing tile palette data into extra tile map storage, for a total of 6 kB
- makes the tiles read palette data from `RAM_SPRPAL` (just as in [my original attempt at an attribute map](../../attrmap/))
- adds support for more tile map sizes, to make use of the available tile map memory

A short demo video can be found at https://youtu.be/RMPqGM-1orw

This mod is written on top of the [sprite palettes mod](../../sprite_palettes/). It is built on the features of the [512 tiles mod](../../512_tiles/), which unifies the tile and sprite graphics RAMs to be able to display more than 256 simultaneous tiles (and adds the ninth bit interface used for the extra attribute bits).

New registers
-------------
The mod introduces the registers
- `PIC_MODE` (`0x2819`):
    - bits 0-2, `PIC_BASE`: The tile map starts at tile `512*PIC_BASE` in the tile map RAM (`RAM_PIC` followed by `RAM_PAL`)
    - bits 3-4: Tile map width, 0-3 maps to (32, 48, 64, 96)
    - bits 5-6: Tile map height, 0-2 maps to (32, 48, 64)
    - bit 7: Enable attribute mode (2 bytes per tile map entry)
- `CHR_PALBASE` (`0x28d3`): The tile palettes begin at color index `CHR_PALBASE*4` in `RAM_SPRPAL`
- `CHR_ATTR_MASK` (`0x28c3`): Used for tile palette selection when attribute mode is off (see below)

Tile map entry format
---------------------
When attribute mode is enabled, the format of a tile map entry is

    ee pppppptt tttttttt

with two ninth bits `ee` (see the [512 tiles mod](../../512_tiles/)) and two bytes. This contains a 10 bit tile index `tttttttttt` and an 8 bit palette index `eepppppp`.
(The tile map entry format is updated in [version 2](v2/).)
The color index of a tile pixel is computed as

    (palette_index + CHR_PALBASE)*4 + pixel_value

When attribute mode is off, `palette_index = tile_index & CHR_ATTR_MASK`. This allows to reuse the same 4 color palette for several tiles also in this mode, to make some space for sprites palettes.

Tile map sizes
--------------
The following tile map sizes are recommended, depending on video mode:
- 400x300: 64x48 = 3k tiles
- 640x240: 96x32 = 3k tiles
- 320x240: 48x32 = 1.5k tiles, or 64x32 = 2k tiles
- 200x300: 32x48 = 1.5k tiles, or 32x64 = 2k tiles

All tile map formats are stored tightly packed, row by row.
With 1.5k tiles per tile map, there's space for double buffering the tile map even in attribute mode. Use the `PIC_BASE` field to switch which tile map to show.
The address computation that is used to look up the needed tile map entries is built to handle tile map sizes of up to 4k tiles.

Tile map memory map
-------------------
As seen by the tile map renderer, tile map memory is organized as

    0k 1st half of RAM_PIC
    2k 2nd half of RAM_PIC
    4k RAM_PAL
    6k RAM_PAL (repeated)

The start address (in bytes) of the tile map in this space is given by `1024*PIC_BASE` in attribute mode, or `512*PIC_BASE` otherwise.
`PIC_MODE` configurations that fit the whole tile map into from the first 6 kB are probably the most useful,
but the effects of reading outside of this region can be predicted from the memory map above.

Smooth scrolling
----------------
Smooth scrolling is supported without visual artifacts for all tile map sizes that are big enough to cover a full screen of pixels.
The scrolling registers should be set such that

    0 <= SCROLL_X < 2*tilemap_width_in_pixels  - screen_width
    0 <= SCROLL_Y < 2*tilemap_height_in_pixels - screen_height

This means that as long as `tilemap_width_in_pixels <= screen_width` and `tilemap_height_in_pixels <= screen_height`, it's enough that

    0 <= SCROLL_X < screen_width
    0 <= SCROLL_Y < screen_height

The cause for these constraints is the way that tile map wrapping is implemented. When drawing the tile map for the current pixel:
- Calculate the coordinates as `(x, y) = (screen_x + SCROLL_X, screen_y + SCROLL_y)` (unsigned)
- If `x >= tilemap_width_in_pixels`, use `x_wrapped = x - tilemap_width_in_pixels`, otherwise `x_wrapped = x` (and same for `y`)
- Look up the tile for `(x_wrapped, y_wrapped)` in the tile map

Initial state
-------------
The initial contents of the Gameduino's RAMs and registers are set up to display the Gameduino splash screen, which uses 16 color sprites (with a single palette) for most of the logo, and tiles for the rest.
This mod makes some changes to preserve the appearance of the splash screen despite the fact that tiles and sprites now share palette space:
- The initial contents of `RAM_SPRPAL` are now the original initial contents of `RAM_PAL`, except for that the sprite palette has been put into the last 16 colors (which were unused)
- The initial value of `SPR_PALBASE_16` (see the [sprite palettes mod](../../sprite_palettes/)) is set to 252, to make the logo sprites use the sprite palette starting at `252*4 = 1008 = 1024 - 16`

Additional options
------------------
The mod also introduces two synthesis time options:
- `SUPPORT_8BIT_RAM_PIC`: disable if the original mode with one byte per tile map entry is not needed. This saves a bit more than 20 slices in the xc3s200a FPGA.
- The positions of `RAM_PIC` and `RAM_CHR` can be swapped in the memory map, which makes the tile map accessible as 6 kB of contiguous memory (see the parameters `MEM_PAGE_ADDR_RAM_PIC` and `MEM_PAGE_ADDR_RAM_CHR` in the source)

Version history
---------------
- Original mod in this directory, updates in `v2/`
- [`v2/`](v2/): Change the tile map entry attribute format to `tt pppppppp tttttttt`, with the option `ATTR_NINTH_PAL_BITS=1` to change it back
