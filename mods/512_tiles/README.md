Mod: 9 bit tile map and unified graphics RAM
============================================
The Gameduino supports a 64x64 x 8 bit tile map `RAM_PIC`, allowing to choose between 256 different graphics tiles. This mod extends the tile map entries to 9 bits, which allows to choose from 512 simultaneous graphics tiles. By default, tile ids 256-511 take their graphics from the first 4k of the sprite graphics RAM (there's only room for 256 tiles in the tile graphics RAM).

In order to do this, the following modifications are used:
- Extending `RAM_PIC` to store 9 bits per entry
- Read/write interface to access 9 bit tile map entries from the host
- Unified pixel read access between the tile and sprite rendering pipelines, effectively forming a combined Pixel RAM from their graphics RAMs
- Organizing the tile graphics RAM `RAM_CHR` into 8 bit entries (instead of 2 bit entries), just like the sprite graphics RAM `RAM_SPRIMG`
- Extending tile id signals in the code from 8 to 9 bits

The mod also adds a base address register `CHR_BASE` (`0x28c0`) to point to the start of the tile graphics in Pixel RAM, see memory map below.

The current version of the mod is written on top of the [video modes mod](../video_modes/).

A short demonstration video can be found at https://youtu.be/bRzL1IFwPW0

Background
----------
The XC3S200A FPGA that the Gameduino code is written for actually stores 9 bits per byte in its block RAMs, which are used to store the bulk of all data in the Gameduino.
This mod makes use of the ninth bit in the block RAMs for `RAM_PIC`. The caveat is that all 9 bits must be accessed as one unit, so the ninth bit can only be read or written when the other bits are. Since the host has an 8 bit interface to the Gameduino, this obviously causes some complications.

The other thing that makes this mod possible is that the Gameduino never renders tile and sprite graphics at the same time, since it can only write one pixel per cycle into the line buffer anyway. Because of this, it never needs to read tile and sprite pixels in the same cycle, so they can share access to the same RAMs.

Ninth bit read/write interface
------------------------------
The mod adds an interface for reading and writing 9 bit values to block RAMs where supported (the only block RAM that supports it in this patch is `RAM_PIC`).
Two registers are added for this purpose:
- `NINTH_READ` (`0x28c8`)
- `NINTH_WRITE` (`0x28c9`)

Each write from the host to block RAM (anywhere in the 32k memory map except `0x2800` - `0x2fff`) takes the ninth bit from the lsb of `NINTH_WRITE`. The write causes `NINTH_WRITE` to be right shifted one step, so up to 8 ninth bits can be written to it in advance, to be used in order.

Similarly, each time that the host reads block RAM, the ninth bit read is shifted into the msb of `NINTH_READ`, right shifting the existing contents. The end result is to make `NINTH_READ` contain the ninth bits from the 8 last entries read from block RAM.

Pixel RAM Memory Map
--------------------
This mod makes tile and sprite graphics be read from the same unified memory space, which we will call Pixel RAM.
The memory map of Pixel RAM covers 32k before it wraps, with `RAM_CHR` repeated in the second half:

     0k | RAM_SPRIMG
     4k | is in the
     8k | first
    12k | 16 k
    16k RAM_CHR, 4k
    20k RAM_CHR, 4k (repeated)
    24k RAM_CHR, 4k (repeated)
    28k RAM_CHR, 4k (repeated)

This is the memory map that the base address register `CHR_BASE` relates to; tile graphics are read starting from address `CHR_BASE*256`. The initial value of `CHR_BASE` is `0x70`, making `CHR_BASE*256` = 28k. This default causes tile ids 0-255 to read their graphics from the last repetition of `RAM_CHR`, while tile ids 256-511 wrap around to read graphics from the first 4k of `RAM_SPRIMG`.

Version history
---------------
- v1: Initial version (in this directory)
- `v2/`: Based on v4 of [mods/video_modes](../video_modes), with further bug fixes
