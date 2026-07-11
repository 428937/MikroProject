# Assembly Rhythm Game

A 16-bit x86 Assembly game developed for DOS environments. This project demonstrates low-level hardware interaction, real-time timing, and modular logic design.

## Overview
The game challenges the player to press random keys ('a' through 'h') within a decreasing time window. It is written in 8086 Assembly and runs in DOS real mode.

## Modular Structure
The source code is organized into distinct functional blocks to ensure clarity and maintainability:

*   **RNG Module:** Uses BIOS INT 1Ah (System Timer) to generate pseudo-random characters. Includes a "duplicate check" to prevent the same character from appearing twice in a row.
*   **UI/Render Engine:** Instead of heavy screen clearing, it uses Carriage Return (ASCII 13) for efficient line-based updates.
*   **Timing & Input Loop:** A non-blocking loop that simultaneously tracks BIOS ticks and polls the keyboard buffer (INT 16h).
*   **Difficulty Controller:** A dynamic logic block that scales the `bekleme_suresi` (waiting time) based on the user's `kombo` count.
*   **Utility Functions:** Contains `sayi_yazdir`, a reusable procedure for binary-to-ASCII conversion.

### How to Run
1.  Assemble the code using **TASM** or **NASM**.
2.  Run the resulting `.COM` file in **DOSBox**.
3.  Objective: Press the target key before the timer hits zero
