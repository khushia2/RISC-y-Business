# RISC-y-Business

Won 2nd place (out of 50 teams) in the Design Competition :)

In this project, my team implemented a 5-stage pipeplined RV32I microprocessor in SystemVerilog. The processor is split into the following 5 stages: fetch, decode, execute, memory and write-back with buffers between the units. There is a opcode-dependent control word (in the form of a struct) that is passed down through the processor to control the stages of the pipeline.

# Feature Highlights:
* Memory Hierarchy (I-Cache, L1/L2 D-Cache, Arbiter)
* Stalling
* Hazard Detection
* Data Forwarding Unit
* Tournament Branch Predictor
* Branch Target Buffer
* Stride Prefetcher

# Analysis of Processor Performance:
The test code contained 43605 instructions. A simple RV32I CPU design took 186887 cycles to run test code. Our design took 80974 cycles to run test code. 
Our design was one of the fastest and consumed the least power thus winning us 2nd place in the competition.
