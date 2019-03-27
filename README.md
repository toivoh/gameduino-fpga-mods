gameduino-fpga-mods
===================
Investigations and modifications of the FPGA code from @jamesbowman's Gameduino file repository

What is it?
-----------
Gameduino is a game adapter for Arduino - or anything else with an SPI interface - built as a single shield that stacks up on top of the Arduino and has plugs for a VGA monitor and stereo speakers.

The verilog hdl code for the FPGA in the Gameduino is released under a BSD license. With minor modifications, it can be used on other boards and in other FPGAs.

Legal stuff
-----------
This project was created by James Bowman <jamesb@excamera.com>. I strongly recommand you to visit his website first as it always will contain the more recent and official information about the Gameduino: [http://excamera.com/sphinx/gameduino/index.html]

What's in this repository
-------------------------
This repository is focussed on the Gameduino FPGA code, and making it usable in broader context. There's
- a description of what I've figured out about the design below,
- some modifications of the orignal code intended to make it easier to reuse, [described here](restructured/README.md) (code in the `restructured/` directory), and
- Gameduino mods:
    - one that demonstrates how one can unify the tile and sprite palettes to make room for an attribute map with 4 bits per tile position (see [mods/attrmap/](mods/attrmap/))
        - a reworked version with one attribute byte per tile position (see [mods/tile_attr_map/v2/](mods/tile_attr_map/v2/))
    - one that adds additional video modes (see [mods/video_modes/](mods/video_modes/))
    - one that allows to use 512 simultaneous background tiles instead of 256 (see [mods/512_tiles/](mods/512_tiles/))
    - one that allows 4/16 color sprites to use many more palettes, sharing the main sprite palette between all sprites (see [mods/sprite_palettes/](mods/sprite_palettes/))

The copy that I used as a basis for this repository was taken from [https://github.com/Godzil/gameduino].

Overview of the Gameduino hdl design
====================================
The bulk of the Gameduino's FPGA code, including the video pipeline, can be found in the module `top` in `top.v`. For more information about the Gameduino as seen from the outside, including the hardware interface, check out [https://excamera.com/sphinx/gameduino/].

Here, I want to talk a bit about how the Gameduino uses its memory resources, and how the graphics pipeline is built.

A brief introductino to memory resources in FPGAs
-------------------------------------------------
The Gameduino's hdl was written for the XC3S200AN FPGA, and is adapted to the resources that are available there.

The FPGA has the following memory resources:
- 8 _block RAMs_, 4.5 kB each, which can be used as 16 2.25 kB block RAMs; 36 kB in total
	- Each block RAM has two read/write ports that can be used to address between one and 36 bits at the same time (but the access width can't be changed on the fly)
	- The block RAMs store one parity bit for each regular byte (that's why it's 4.5 kB and not 4 kB). These can be used for regular storage, but can only be accessed when the block RAM is set up to address at least one byte at a time
- 28 kbit (3.5 kB) of _distributed RAM_. This is in fact logic resources (LUTs) that can be used as RAM, each LUT holds 16 bits (about half of the LUTs can used in this way)
- 3584 flip flops (1 bit each), one for each LUT. Typically used to store the output of the corresponding LUT if desired

Block RAMs are the biggest, while flip flops are the easiest to use locally. As the name implies, block RAMs have to be used as blocks, since each can only be accessed through two read/write ports.
Most of the memory is available as block RAM, and the Gameduino makes full use of it.
It also uses distributed RAM for some smaller memories.

The Gameduino's memory budget
-----------------------------
Looking at the Gameduino's memory map (e.g. as seen in this [poster](https://excamera.com/files/gameduino/synth/doc/gen/poster.pdf)), we can already see how it's using most of its block RAM:
- 64x64 tile map - 4 kB
- tile graphics for 256 tiles x 8x8x2 bits - 4 kB
- 256 tile palettes x 4x2 bytes - 2 kB
- 2x256 sprite records x 4 bytes - 2 kB
- 4 sprite palettes x 256x2 bytes - 2 kB
- 64 sprite images x 16x16 bytes - 16 kB

The registers, which are addressed in a 2 kB window in the memory map, are stored in distributed RAM and flip flops.

Notice how every block is sized to be a multiple of 2 kB, since that's the smallest size block RAM that is individually addressable.
That's just 30 kB though. The final 2 kB are used by the _line buffer_, which stores two lines of 512 pixels x 2 bytes; one being output to the display, and one being drawn.

The video pipeline
------------------
The Gameduino is built to output an 800x600@72Hz VGA signal. The VGA signal contains the pixels of each frame in raster scan order (left to right, top to bottom), with pauses (blanking intervals) between lines/frames (horizontal/vertical blanking).

To use this video format, pixels must be output at a rate of 50 MHz, which is used to output a 400x300 image by 2x upscaling. The Gameduino board only has outputs for 3 bits per color component, but the upscaling logic uses dithering to reach 5 bits per component.

The video pipeline is also clocked at 50 MHz; one cycle per VGA pixel. The only thing that is synced to the horizontal sweep of the VGA signal is the readout of the line buffer for the current line.
While the current line is read and sent out twice to produce vertical upscaling, the pipeline has time to fill the next line in the buffer.

One pixel can be written to the line buffer in each cycle. The process to render the line buffer for the next line proceeds as follows:
- There's one sub-pipeline for background rendering and one for sprite rendering
- First, the background pipeline takes 400 cycles to fill the line buffer with tile graphics
- Then, the sprite pipeline takes over and begins to draw (the current line for) one sprite at a time into the line buffer, skipping over sprites that don't overlap with the current line

Each line is 1040 cycles including blanking, so the pipeline has almost 2080 cycles to draw one line. After subtracting 400 pixels for the background, there's time for at most 1680 pixels for sprites, or 105 sprites. (The documentation says max 96 sprites per line, and there's probably some overhead that keeps it from reaching up to 105.)

Both sub-pipelines have about 4 stages, going through three memories in turn: (names of related signals in the code in parentheses)
- The background pipeline passes through the memories for (in order)
	- tile map (address: `picaddr` -> out: `glyph`)
	- tile graphics, (out: `charout`)
	- tile palette (out: `char_matte`)
  resulting in the final pixel value in `char_final`, to be written at x coordinate `comp_workcnt - 3` (-3 to compensate for the depth of the pipeline).
- The sprite pipeline passes through the memories for (in order)
	- sprite records (address: `s1_count` -> out: `sprval_data`)
	- a 16-element fifo, to buffer up visible sprites while working on drawing the background or previous sprites (out: `s2_out`, containing sprite data and id)
	- sprite graphics (address: `sprimg_readaddr` -> out: `sprimg_data`)
		- a whole byte is always read, then 2 or 4 bits are extracted from it if the sprite is in 2 or 4 bpp mode
			- each byte in a sprite image can contain pixels from two 4 bpp sprites or four 2 bpp sprites
	- sprite palette (address: `sprpal_addr` -> out: `sprpal_data`)
  resulting in the final pixel value in `s4_out`, to be written at x coordinate `s4_compaddr`.

The pipeline uses one port on each block RAM, while the other is reserved for access by the host (except for the line buffer, which is set up with one read port and one write port). When reading block RAM, the result is available in the next cycle, so one value can be read (or written) per cycle. This means that the three memories that are accessed by a sub-pipeline must be in different block RAMs, since they are all read in every cycle.

Other things that are included in the Gameduino code
----------------------------------------------------
The video pipeline is not the only functionality present in the Gameduino code, though it uses most of the memory resources. There's also code in the `top` module for
- Sweeping the VGA pixel coordinates and generating sync signals
- Audio output
- Host access to the Gameduino's registers and memories
- A small processor, referred to as the _coprocessor_ ([see the coprocessor documentation here](https://excamera.com/sphinx/gameduino/coprocessor.html))
	- The coprocessor can access the Gameduino's memories through the same port as the host, and is blocked when the host is using the port
- Screenshot functionality (line readout)
- SPI passthrough functionality to access the SPI flash on the Gameduino board
