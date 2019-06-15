Mod: FMicrosynth integration
============================
This mod adds an option to use the [FMicrosynth programmable sound synthesizer](https://github.com/toivoh/fmicrosynth) as an alternative to the Gameduino's additive sound synthesis. The synthesizer can be programmed to do eg simple FM synthesis and square/pulse/sawtooth/triangle/noise/sine waveforms.

New registers:
- `FMS_CONTROL (0x28e0)`: Set to 1 to put the synth in reset
- `FMS_STATUS (0x28e1)`, read only: Bit 0 is clear when the synth is waiting to be triggered to start calculating the next sample, and set otherwise
- `FMS_RAM (0x2a00-0x2aff)`: The FMicrosynth's RAM
    - replaces the `VOICES` registers when using FMicrosynth

FMicrosynth is programmed through its `code[]` and `data[]` memories, which are accessible as follows:
* `data[addr]` (2 bytes) is accessible at `FMS_RAM + 4*addr`
* `code[addr]` (2 bytes) is accessible at `FMS_RAM + 4*addr + 2`

where `addr` goes from 0 to 63.

The sampling rate has been set to

    fs = 50 MHz / 1024 = 48828.125 kHz

FMicrosynth integration is enabled with the define `USE_FMICROSYNTH`.
The mod also adds a PWM based audio DAC as an alternative to the Gameduino's existing delta-sigma converter, which is enabled by the define `USE_PWM_DAC`.

A short demo video can be found at https://youtu.be/o0-lQ3pMrYY

The code for this mod is written on top of the code for the [sprite scaling mod](../sprite_scaling/).
