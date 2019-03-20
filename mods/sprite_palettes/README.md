Mod: Additional palette selection bits per sprite, unified sprite palette
=========================================================================
The original Gameduino supports four palettes for 256 color sprites (1024 colors in total), but only two (separate) palettes each for 4 and 16 color sprites, respectively.
This mod makes all sprites use palette colors from the same main sprite palette (`RAM_SPRPAL`), and allows 4 and 16 color sprites to choose between many more sprite palettes (sub-palettes of `RAM_SPRPAL`).

This mod builds on the [512 tiles mod](../512_tiles/), which introduced the ability to store an extra bit per byte in the tile map. This mod makes these ninth bits availble in the sprite records (`RAM_SPRVAL`) too, for a total of 36 bits per sprite record.

The four extra bits (`eeee`) in the sprite record are used for palette selection.
If you want to use them, the recommended procedure for writing a sprite record is:
- First, write eeee to `NINTH_WRITE`
- Then, write the the four bytes that make up the rest of the sprite record to `RAM_SPRVAL`, in order
- After this, the value that was written to `NINTH_WRITE` has been right shifted by four. If you don't want to keep it, write a zero to `NINTH_WRITE`.

Each write to a byte in `RAM_SPRVAL` will update the corresponding extra bit from `NINTH_WRITE`.

New registers:
- `SPR_PALROT_MASK` (`0x28c2`) - Which of the sprites' rotation bits should be used for palette selection instead?
    - bit 0: diagonal flip bit for 4 color sprites
    - bit 1: horizontal flip bit for 4 color sprites
    - bit 2: vertical flip bit for 4 color sprites
    - bit 3: diagonal flip bit for 16 color sprites
- `SPR_PALBASE_4` (`0x28d0`) - The 4 color palettes start at color index `4*SPR_PALBASE_4` in the main sprite palette
- `SPR_PALBASE_16` (`0x28d1`) - The 16 color palettes start at color index `4*SPR_PALBASE_16` in the main sprite palette

The color index into `RAM_SPRVAL` is calculated differently for 4/16/256 color sprites:
- 4 color sprites: `(vhdeeeepcc) + 4*SPR_PALBASE_4`
- 16 color sprites: `(deeeepcccc) + 4*SPR_PALBASE_16`
- 256 color sprites: `(ppcccccccc) + 16*(eeee)`

where
- `vhd` are the sprite's rotation bits (vertical/horizontal/diagonal flip), zeroed in this calculation unless the corresponding bit in SPR_PALROT_MASK is set
- `eeee` are the sprite's ninth bits
- `p` are the sprite's original palette selection bits (two for 256 color sprites, one for the other)
- the `c` bits are given by the sprite's pixels

A short demo video of the mod is available at https://youtu.be/jUV9lBzyr1g

Note: The `RAMB16_S9_S36` primitive used to implement `RAM_SPRVAL` in the Gameduino code didn't seem to synthesize correctly for my FPGA when I tried it (the ninth bits were always zero). If you encounter this problem, you can enable the `RAM_SPRVAL_INFERRED` define to use an alternate implementation (which did take more block RAM when I synthesized it for my FPGA, though).
