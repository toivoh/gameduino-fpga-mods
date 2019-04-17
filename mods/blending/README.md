Mod: Blending modes
===================
This mod adds a number of blending modes to the Gameduino, which are different ways to combine a foreground pixel to be written into the line buffer
with the background pixel that is already present there. The blending mode is specified by the alpha value of the foreground pixel.
The palette entries' alpha values have been extended to 3 bits, to be able to choose between more blending modes.

This mod is based on the [draw control mod](../draw_control/), which allows to draw tiles both behind and on top of sprites.
The blending modes can be used for both sprite and tile graphics.

The palette entry format has been extended with two additional alpha bits `aa` (stored as ninth bits), into

    aa Arrrrrgggggbbbbb

the full 3 bit alpha value is taken as `alpha = Aaa`. To set a palette entry with 3 bit alpha, first write the aa bits to 
`NINTH_WRITE (0x28c9)`, then write the remaining two bytes to `RAM_SPRPAL`, in order.

Blending is done per channel (r, g, b). The resulting r value (`blend`) is 
calculated from the current pixel's r value (`fg`) and the background 
pixel's r value (`bg`), depending on the blending mode (`alpha` value): (and the same for 
g and b values, respectively)

    alpha = 0 - 4, Alpha blend:     blend = alpha*bg/4 + fg (saturated)
    alpha =     0, Opaque:          blend = fg
    alpha =     4, Add:             blend = bg + fg (saturated)
    alpha =     5, Subtract:        blend = bg - fg (saturated)
    alpha =     6, Multiply/darken: blend = bg,       when fg = 0
                                          = fg*bg/32, otherwise
    alpha =     7, Brighten:        blend = bg,                 when fg = 0
                                            fg*bg/32 + (32-fg), otherwise

The special case for `fg = 0` for the darken and brighten modes allow them to pass a color channel through unmodified.
The strongest effect of these modes is achieved with `fg = 1`, which gives `blend = 0` for darken and `blend = 31` for brighten.

Blended pixels take two cycles to draw instead of one, because an additional cycle is needed to read the background pixel from the line buffer.
Transparent and opaque pixels still take just one cycle to draw.
When bit 7 of the `DRAW_MODE (0x280d)` register is clear, all pixels with `alpha=4` are taken as transparent. When the bit is set,
only palette entries with value `0x8000` are taken as transparent, and all other cases with `alpha=4` invoke the additive blending mode.

The code changes in this mod are mostly concerned with
* Blending, implemented in the `blender` and `blender_channel` modules
* Adding the ability to stall the pixel pipeline while waiting to read the background pixel from the line buffer (by lowering the `pipe_en` signal)

The blending implementation uses 6 18x18 multipliers to do most of the heavy lifting (the xc3s200a has 16 of them, and only one was used if you disable the non-PCM audio.)
Each multiplier is used to calculate a sum of products, such as `alpha*bg +- 4*fg`. One multiplier is used for the darken/brighten modes, and one for the others.
A multiplexer is then used for each color channel to choose between the two multiplier results, and the values 0 and 31 (for saturation).

The mod can be seen in action at https://youtu.be/mhq9uObLlEk

Limitations
-----------
In the current implementation, in 640x240 mode, blending only works correctly for the leftmost 512 pixels on the screen (and not for x coordinates 512-639).
The reason is that the line buffer is implemented differently for these last pixels, and reading of the background pixel wasn't implemented for this part.
It would be quite straightforward to do, but would take some more logic resources.
