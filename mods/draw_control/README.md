Mod: Draw Control and Multi-layered Rendering
=============================================
This mod adds a number of features that allow the host CPU, and even more the j1 coprocessor, to control what the Gameduino draws into the line buffer (and thus, what is displayed on screen).

New registers:
- `DRAW_MODE (0x280d)`: (replaces and extends `SPR_DISABLE`, which was at `0x280a`)
    - bit 0: disable sprites
    - bit 1: disable tiles
    - bit 2: draw sprites behind tiles instead of in front
  When `DRAW_MODE` is 0, the Gameduino will start scanning for sprites on the same line as soon as tile drawing starts, and buffer them in a FIFO for sprite drawing (just like before)
- `SPR_BASE` (`0x280a`, 2 bytes): Index of the first sprite to draw
    - `SPR_PAGE (0x280b)` is now the MSB of `SPR_BASE`, and works as before if you leave the LSB at its initial value of 0
- `SPR_END (0x2816)`: Low byte of the index of the last sprite to draw
    - Sprite drawing stops after LSB of sprite index matches `SPR_END`
    - `SPR_BASE` and `SPR_END` can specify a sprite range of 1-256 sprites, disable sprites with `DRAW_MODE` if none are desired
- `WINDOW_X0` (`0x281a`, 2 bytes), `WINDOW_X1` (`0x281c`, 2 bytes): All drawing is clipped to `WINDOW_X0 <= x <= WINDOW_X1`
    - `WINDOW_X1` must be `>= WINDOW_X0` for clipping of tile layer to work
    - Can set `WINDOW_X0 = WINDOW_X1 = x`, where `x` is to the right of the screen, to disable all drawing (or use `DRAW_MODE = 3`)

There's also a new register that is only accessible from the j1 coprocessor, `DRAW_CONTROL` (`0x801e`, write only):
- bit 0: Restart drawing to the line buffer
- bit 1: Wait for draw done
- bit 2: Wait for new line
- bit 3: Wait for new frame
When waiting, j1 is paused until all the specified events have occurred.

To support these features, the way that the line buffer is cleared for a new line has also been changed: Before, the line buffer was cleared by drawing over it with the tile background. Any transparent pixel in the background was explicitly replaced with `BG_COLOR`. Now, the line buffer is cleared to `BG_COLOR` while it is being read out (for the second time), which removes the burden to clear it from the draw stage. Tile background drawing has also been updated to support transparent pixels.

With these additions, the j1 coprocessor can make the Gameduino take several passes to draw into the line buffer for the same line:
- Different passes can
    - use different register settings
    - draw different sprite ranges
    - draw to different spans of x coordinates
- The `DRAW_MODE` register can be used to set up a sprite-only or tile-only draw pass

This mod is based on v2 of the [text colors mod](../text_colors/).

There's a video at https://youtu.be/CsM6kae2PVE that demonstrates a few of the things that can be done with the mod.

Shadow registers
----------------
This part of the change was done to save some logic resources in the implementation of common registers (of which the mod adds a few).

Most of the Gameduino's common registers are stored in flip flops, so that the logic can read them all at the same time, every cycle. Most are only written by the host (and the j1 coprocessor). 
Looking at how this is implemented, very few LUTs are needed to write a register to flip flops; each register needs one write enable signal that goes high when that specific address is written to.
But to read the values back from a register stored in flip flops, you basically need one multiplexer for each bit in every such register that can be read. This adds up to quite a lot of logic resources.

For registers that are only written by the host, we can do better. When such a write comes in, this mod makes the Gameduino store the same register value both to the flip flops
(as before) and to a set of _shadow registers_ in distributed RAM. When reading, we return the value from the shadow register instead of the flip flops.
This turns out to give some nice savings, even with the extra LUTs needed for the distributed RAM, since the distributed RAM contains all the needed addressing machinery already.

One caveat is that we must make sure that the register values stored in flip flops and shadow registers are consistent even at startup.
The mod introduces a number of parameters to hold the initial values of the shadowed registers that are not initialized to 0,
and those are used for initial values of both flip flops and distributed RAM.

In this mod, the registers in the `0x2804 - 0x281d` and `0x28c0 - 0x28c7` memory ranges are shadowed; the former in a new distributed 32x8 bit RAM `shadow1_regs`,
the latter in the top half of the `palbases` RAM (the bottom part is used for the `SPR_PALBASE_4` - `CHR_PALBASE_BG` registers in the `0x28d0` - `0x28d7` range).
