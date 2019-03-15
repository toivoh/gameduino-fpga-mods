Mod: Add more video modes
=========================
The original Gameduino outputs an 800x600@72Hz VGA video signal. This mod adds a video mode register at address 0x2818, supporting the following mode values:
* 0 - 400x300@72Hz (original)
* 1 - 640x240@60Hz, with 128x32 tile map and (x: 10 bit, y: 8 bit) sprite coordinates
* 2 - 200x300@72Hz
* 3 - 320x240@60Hz

In mode 1, the tile map is 128x32 instead of 64x64. The sprites have only 8 bits of y position, and the 9th bit of y is used as the 10th bit of x instead.

These four modes are basically combinations of two parameters that the patch makes variable:
* VGA format can be switched between 800x600@72Hz and 640x480@60Hz
    * 800x600@72Hz uses a pixel clock of 50 MHz
    * 640x480@60Hz uses a pixel clock of 25 MHz, and is actually realized by spending two cycles per pixel
        * This effectively makes it a 1280x480@60Hz mode, but VGA doesn't really care about horizontal resolution, so the VGA timing is the same as for 640x480@60Hz
        * I also tried sending the 1280x480@60Hz signal to my monitor over DVI, which worked fine and gave me narrow pixels
* When reading the line buffer, the width of each output pixel can be doubled from two to four

The width of the lines rendered into the line buffer is adjusted to account for how many pixels will be visible.

Special adjustments were needed for the 640x240 mode:
* Interpreting the tile map as 128x32 and sprite coordinates as (x: 10 bit, y: 8 bit) to cover the whole screen width
* Adding a secondary, 128 pixel wide line buffer to be used for the pixels that don't fit into the existing 512 pixel wide line buffer

There's some parameters in the first lines of the patch that allow to enable/disable some of the different extensions introduced,
to switch how the tile map is addressed in 128x32 mode, and to disable the audio support if needed.
The mod takes some additional logic resources, but definitely less than what I gained by disabling audio when I tested.

This is also a considerably bigger change than the attrmap mod. A lot of it is concerned with making the VGA timing parameters changeable, with two alternate settings.
But there's also assumptions that had to be changed in various places about screen width, number of bits needed to represent x coordinates, etc,
and a number of smaller features needed to support the 640x240 mode.

A short demonstration video of the mod can be seen at https://youtu.be/OuJSkkX6KHA

Version history
---------------
- Original mod in this directory, updates in `v2/`, `v3/`
- `v2/` updates:
    - Based on new version of `restructured/top.v`, with the original `clka` input
    - Split dual ported `composer_2` RAM into two single ported RAMs (one line being read and one written) for reduced logic usage
    - Take out the whole audio functionality when `USE_AUDIO` is off - missed removing the audio registers in the first verison
    - Improve compatibility of conditional instantiation code
- `v3/`: Add option `USE_PCM_AUDIO` (default on) to use just the PCM part of the audio functionality
