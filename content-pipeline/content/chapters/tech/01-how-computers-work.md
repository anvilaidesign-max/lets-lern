---
topic: tech
position: 1
title: How computers work
summary: Bits and binary, logic gates, the CPU's fetch-decode-execute cycle, memory and storage, and how software becomes instructions.
difficulty: 1
sources:
- Wikipedia: Binary number | https://en.wikipedia.org/wiki/Binary_number
- Wikipedia: Logic gate | https://en.wikipedia.org/wiki/Logic_gate
- Wikipedia: Central processing unit | https://en.wikipedia.org/wiki/Central_processing_unit
- Wikipedia: Computer memory | https://en.wikipedia.org/wiki/Computer_memory
---
## Everything is bits

A computer stores and processes everything (numbers, text, photos, music, this sentence) as **bits**: values that are either 0 or 1. Physically, a bit is a voltage that is low or high, a tiny magnetised region, or charge trapped in a memory cell. Eight bits make a **byte**, which can hold 2⁸ = 256 different values.

Numbers use **binary** (base 2), where each position is worth double the one to its right:

> 1011 in binary = 8 + 0 + 2 + 1 = 11 in decimal

Programmers often use **hexadecimal** (base 16, digits 0–9 and A–F) as shorthand, because one hex digit is exactly four bits: FF = 1111 1111 = 255.

Text is stored with codes. **ASCII** gave each English character a number (A is 65). **Unicode** extends this to over a hundred thousand characters, covering the world's scripts and emoji, and UTF-8 is the most common way to store it.

## Logic gates

Computers calculate with **logic gates**, circuits built from transistors:

- **AND:** output 1 only if both inputs are 1.
- **OR:** output 1 if at least one input is 1.
- **NOT:** flips 1 to 0 and 0 to 1.
- **XOR:** output 1 if the inputs are different.

Combine gates and you can add numbers: a **half adder** uses XOR for the sum bit and AND for the carry. Chain adders together and you have arithmetic. A modern processor is billions of transistors forming gates like these, switching billions of times per second.

## The CPU

The **central processing unit** runs programs. Its main parts are:

- the **control unit**, which directs the flow of instructions,
- the **arithmetic logic unit (ALU)**, which does maths and comparisons,
- **registers**, tiny ultra-fast storage slots inside the CPU.

The CPU repeats one cycle endlessly: **fetch** the next instruction from memory, **decode** what it means, **execute** it, then move on. The **clock** keeps the steps in time; a 3 GHz CPU ticks 3 billion times per second. Modern CPUs have several **cores** (independent processors on one chip) and overlap many instructions at once (pipelining), so they do far more than one instruction per tick.

## Memory and storage

Computers use a hierarchy, trading speed for size and cost:

- **Registers and cache:** inside the CPU, fastest, measured in kilobytes to megabytes.
- **RAM (main memory):** fast working space for running programs, measured in gigabytes. It is **volatile**: it forgets everything when power is lost.
- **Storage:** SSDs (flash memory) and hard drives keep data without power, measured in hundreds of gigabytes to terabytes, but much slower than RAM.

When you open an app, it is copied from storage into RAM so the CPU can reach it quickly. A computer with too little RAM slows down because it keeps swapping data back to storage.

![The CPU fetches, decodes and executes instructions; memory trades speed for size.](cpu_memory)

## From code to instructions

Programmers write in languages like Python, Java or Dart, which people can read. A **compiler** translates the whole program into the processor's **machine code** ahead of time; an **interpreter** translates and runs it line by line. Either way, the CPU only ever executes simple machine instructions such as "load this value", "add these two registers" and "jump to this instruction if the result is zero".

The **operating system** (Windows, Android, Linux, iOS) sits between programs and hardware. It shares the CPU between apps, manages memory, controls files and devices, and enforces security so that one app cannot read another's data.

## Why it keeps getting better

For decades, **Moore's law** held: the number of transistors on a chip doubled roughly every two years, making computers faster and cheaper. As transistors approach atomic sizes, progress now comes increasingly from more cores, specialised chips (GPUs for graphics and AI) and smarter chip design.

# Key points
- Computers store everything as bits; a byte is 8 bits with 256 possible values.
- Binary: each place is worth double; hexadecimal digits are 4 bits each.
- Logic gates (AND, OR, NOT, XOR) built from transistors perform all calculation.
- The CPU runs a fetch-decode-execute cycle, timed by a clock.
- RAM is fast but volatile; storage keeps data without power but is slower.
- Compilers and interpreters turn human-readable code into machine instructions.

# Quiz
Q: What is binary 1101 in decimal?
- 11
* 13
- 15
- 1101
> 8 + 4 + 0 + 1 = 13.

Q: How many different values can one byte hold?
- 8
- 16
* 256
- 1024
> A byte has 8 bits, and 2⁸ = 256.

Q: Which gate outputs 1 only when both inputs are 1?
* AND
- OR
- XOR
- NOT
> AND needs both inputs to be 1. OR needs at least one; XOR needs them to differ.

Q: What happens to data in RAM when the power is switched off?
- It is saved to the cloud
* It is lost, because RAM is volatile
- It stays until the next day
- It moves to the CPU
> RAM needs power to hold its data. Files you want to keep must be saved to storage.

Q: What is the three-step cycle a CPU repeats?
- Read, write, delete
* Fetch, decode, execute
- Input, output, save
- Compile, link, run
> The CPU fetches an instruction, decodes it, executes it, then fetches the next.
