Mod: Sprite scaling
===================
This mod adds upscaling of sprites. Sprites can be scaled 1x/2x/3x/4x in x, and 1x/2x/4x in y.

New register: `SPR_SIZES (0x28c6)`
- bits 0-1: X scaling for size class 0, `0 => 1x, 1 => 2x, 2 => 3x, 3 => 4x`
- bits 2-3: Y scaling for size class 0, `0 => 1x, 1 => 2x, 3 => 4x`
- bits 4-5: X scaling for size class 1
- bits 6-7: Y scaling for size class 1

By default, all sprites belong to size class 0.
By setting bit 4 of `PALROT_MASK (0x28c2)`, the sprite's vertical flip bit (bit 11 in the sprite record)
is used to select size class instead of for flipping or palette selection.

Sprites still take one cycle to draw per pixel, so eg only half as many 2x wide sprites can fit on the same line
compared to 1x wide sprites.

A short demonstration video can be seen at https://youtu.be/lBBlKjgIfdQ

The code for this mod is based on the [tile flip mod](../tile_flip/).

Limitations
-----------
Y scale factors above 1x don't work correctly in 640x240 mode for sprites that are partly above the screen.

Sprite size and scaling constraints
-----------------------------------
This section aims to give some background on how much sprite scaling is possible without deeper changes to the Gameduino code.

### Sprite size
The usable sprite size is limited by the difference between the size of the visible screen and the range of the sprite coordinates.

The 400x300, 320x240, and 200x300 modes use 9 bits per sprite coordinate, so the sprite coordinates can be seen to occupy a 512x512 space that wraps around.
To avoid ambiguities when a sprite crosses one of the screen boundaries, sprites have to be small enough that they exit completely on one side of the screen before they would reenter on the other.
The strictest constraint comes from the 400x300 mode. For this mode to work correclty, no sprite can be larger than 112x212 (400+112 = 300+212 = 512). For 16x16 sprites, that means max 7x sprite scaling in x, and max 13x scaling in y.

The sprite coordinates in 640x240 mode use 10 x bits and 8 y bits, for a space of 1024x256. The maximum sprite size becomes 384x16, so we could support up to 24x scaling in x, but there's no room for y scaling.

### Sprite scaling factors
It's quite easy to do sprite scaling by an integer factor `nx` in the x direction: When rendering a sprite to the line buffer, just keep writing pixels further to the right, but only update the read pixel once every `nx` steps (which is what the mod does).

For y scaling, for each line, we instead have to figure out whether a given sprite overlaps that line, and if so, at which height. The original Gameduino code uses the difference between the sprite's y value and the y value of the current line for this. To scale up by a factor of `ny`, we have to divide the y difference by `ny`. For that reason, the mod only supports power of two scale factors in the y direction, since they are ease to divide with (and those shifters probably consume the majority of the mod's added logic resources).

### Putting the constraints together
We see that except for the 640x240 mode, we could handle up to 7x scaling in x and 13x scaling in y (but only in powers of two, so up to 8x). The biggest scale factor that we can support for both axes is 4x, so that's where I put the limit in this mod. I'm not sure how useful bigger scalings would have been anyway.

For 640x240 mode, we can't really get any y scaling anyway. But 2x scaling in x will give the sprites square pixels, so that might still be useful.
