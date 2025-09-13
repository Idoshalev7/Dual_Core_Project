# Dual-Core DLX with SyncBox and Atomic Operations

## Overview  

This project is a final-year undergraduate project in Electrical Engineering at Tel Aviv University.  
It presents the design, implementation, and testing of a **dual-core DLX system** with hardware support for atomic operations and shared external memory access.

The system consists of **two DLX cores** connected to a shared external memory bus through a **SyncBox** module, which handles reservations, arbitrates access, and ensures correct operation under concurrent memory requests.  
The design includes support for `LR`, `SC`, `SWAP`, and `AMOADD` instructions, enabling safe parallel execution on shared data.

The project demonstrates that a lightweight synchronization mechanism can provide near-2× performance improvement on parallel workloads such as matrix multiplication and convolution, with only modest area and power overhead, while maintaining full correctness.

---

## Features  

- Dual-core DLX system with shared external bus  
- **SyncBox** for bus arbitration and reservation tracking  
- Support for atomic instructions: `LR`, `SC`, `SWAP`, `AMOADD`  
- Deterministic conflict resolution on simultaneous memory access  
- Automatic reservation invalidation on any write to a reserved address  
- Assembly-based testing programs covering corner cases and race conditions  
- Verification with **ModelSim** waveforms and register table checks  
- Real-world implementation and measurement on **Xilinx Spartan-6 FPGA**  

---

## Prerequisites  

- **Python 3.x** – for running the custom assembler  
- **ModelSim** – for simulation and waveform analysis  
- **Xilinx ISE (Spartan-6)** – for synthesis and FPGA implementation  
- **RESA environment** – for hardware-level testing and validation  

---

## Performance Summary  

| Application | Single-Core Cycles | Dual-Core Cycles | Speedup |
| ----------- | ---------------- | ---------------- | ------- |
| Matrix Multiplication | 3,420 | 1,830 | ×1.9 |
| Convolution | 2,510 | 1,340 | ×1.87 |
| Atomic Operations Test | – | – | Correctness Verified |

---

- **FPGA area increase:** ~47% (fits comfortably in xc6slx25)  
- **Power growth:** ~26% (mostly from duplicated datapath; shared clocking/IO keeps it well below ×2 scaling)  
- **Correctness:** Verified via assembly-driven simulation, all edge cases passed  

---

## New Instructions  

We added four custom instructions to enable atomic operations and safe shared memory access:  

1. **lr (Load-Reserved)** – Loads a word from memory and sets a reservation for that address.  
2. **sc (Store-Conditional)** – Stores a word to memory only if the reservation is still valid and updates the **feedback register** with success (1) or failure (0).  
3. **swap** – Atomically swaps a register value with a memory value and updates the **feedback register** with success (1) or failure (0).  
4. **amoadd** – Atomically adds a register value to a memory value, writes the sum back, and updates the **feedback register** with success (1) or failure (0).  

All three operations (`sc`, `swap`, `amoadd`) use the same **feedback register** to report success or failure, allowing software to safely retry failed operations and implement correct synchronization.

---

## Assembling and Running Code  

1. Write DLX-compatible assembly programs.  
2. Use the custom Python assembler to convert `.txt` source files into `.data` format.  
3. Load the `.data` files into ModelSim for simulation and functional verification.  
4. Load the `.cod` files into the RESA environment for FPGA emulation.  
5. Run simulations to validate correctness (ModelSim) and measure performance on hardware (FPGA).  

---

## Authors  

- **Ido Shalev**  
- **Matan Levin**  
- **Supervisor:** Oren Ganon  
- **Institution:** Tel Aviv University, Faculty of Engineering  
