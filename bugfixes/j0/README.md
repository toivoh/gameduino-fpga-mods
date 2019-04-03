Bugfixes for the Gameduino's j0 coprocessor
===========================================
This directory contains a version of the Gameduino's `j0.v` with two bug fixes:
- Wait an extra cycle on loads, to give block RAMs time to respond. The previous implementation would usually produce corrupt data when reading from block RAMs.
- Never signal writes from j0 when it's paused or held in reset. Before, j0 could make unexpected memory writes while held in reset in some circumstances.
