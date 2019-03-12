Restructuring of the Gameduino top module interface
===================================================
The Gameduino's `top` module doesn't only take care of video and sound etc, it also contains some features that are very specific to the Gameduino PCB.
Some of those features make it harder to reuse the Gameduino code in another FPGA project. This directory contains a version of `top.v` which is modified so that the code should be easier to reuse.

The `top` module has been broken into two modules; `gameduino_main`, which keeps the bulk of the code, and `top`, which wraps the former module and handles some board specific concerns. It is my intention that the modified `top` module should work the same as the original.

Changes:
- The `top` module takes a clock signal `clka` as input and derives `vga_clk` from it, with twice the frequency. This is the only thing that `clka` is used for; everything else is clocked from `vga_clk`. The `gameduino_main` module takes `vga_clk` as a clock input directly.
- The `MISO` and `AUX` ports of the `top` module are `inout` signals, and `top` will sometimes tristate them. The interface to `gameduino_main` was changed to use only input and output signals
- The `vga_active` signal from the VGA raster scan code is needed to output the video signal over eg DVI or HDMI, so it was exposed as an output of `gameduino_main`
- One of the last restructuring commits pulls out the SPI interface into `top`, leaving `gameduino_main` with something closer to an 8 bit bus interface for memory access from the host

The resulting main module, `gameduino_main`, has a few more interface signals, but I believe that it's easier to reuse. Most of the inputs can be set to zero if they are not used, and the corresponding outputs ignored.
