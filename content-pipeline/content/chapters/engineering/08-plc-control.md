---
topic: engineering
position: 8
title: Control systems, PLCs and industrial networks
summary: Open and closed loop control, PID tuning, how a PLC scans its program, ladder logic basics, SCADA, Modbus and safety circuits.
difficulty: 3
sources:
- Wikipedia: Programmable logic controller | https://en.wikipedia.org/wiki/Programmable_logic_controller
- Wikipedia: PID controller | https://en.wikipedia.org/wiki/PID_controller
- Wikipedia: Ladder logic | https://en.wikipedia.org/wiki/Ladder_logic
- Wikipedia: Modbus | https://en.wikipedia.org/wiki/Modbus
- Wikipedia: SCADA | https://en.wikipedia.org/wiki/SCADA
---
## Open loop and closed loop

An **open-loop** system acts without checking the result: a toaster runs for a set time whether the bread is done or not. A **closed-loop** (feedback) system measures the output and corrects it: a thermostat switches the heater based on the measured temperature. Closed-loop control copes with disturbances, but it can become unstable if it reacts too strongly or too late.

## The PID controller

Most industrial loops (temperature, pressure, flow, level, speed) use **PID** control. The controller computes the **error** e = setpoint − measured value, and sets its output from three terms:

- **Proportional (P):** output proportional to the present error. More gain means a faster response, but P alone leaves a steady-state error (offset), and too much gain causes oscillation.
- **Integral (I):** adds up error over time and keeps pushing until the error is zero, removing the offset. Too much integral action causes overshoot, and it can "wind up" when the output is saturated.
- **Derivative (D):** reacts to how fast the error is changing, damping the response. It is sensitive to noise, so it is often small or unused on noisy signals such as flow.

> u(t) = Kp·e(t) + Ki·∫e dt + Kd·de/dt

A common tuning approach is to start with P only, increase it until the response is quick but not oscillating, add integral until the offset disappears in reasonable time, and add derivative only if needed. Methods such as Ziegler–Nichols give formula-based starting values.

## The PLC

A **programmable logic controller** is a rugged industrial computer designed for control. It replaced walls of relay logic in the 1960s and 1970s. A PLC has a CPU, input modules (digital inputs for switches and sensors, analogue inputs for 4–20 mA signals) and output modules (relays, transistors, analogue outputs).

The PLC runs a continuous **scan cycle**:

- read all inputs into an input image,
- execute the program from top to bottom using that image,
- write the results to the outputs,
- handle communications and diagnostics, then repeat, typically every few milliseconds.

Because inputs are read once per scan, a pulse shorter than the scan time can be missed. Fast signals need interrupt inputs or high-speed counter modules.

## Ladder logic

PLC programming languages are standardised in **IEC 61131-3**: ladder diagram, function block diagram, structured text, instruction list (deprecated in newer editions) and sequential function chart. **Ladder logic** looks like the relay wiring diagrams electricians already knew. Two vertical rails represent power; each horizontal **rung** has conditions (contacts) on the left and an action (coil) on the right.

- A **normally open (NO) contact** passes power when its bit is 1.
- A **normally closed (NC) contact** passes power when its bit is 0.
- A **coil** sets its bit to 1 when the rung is powered.

The classic **start/stop seal-in** (latching) circuit: the start button and a contact of the motor output are in parallel, and the stop button is in series:

> Motor = (Start OR Motor) AND NOT Stop

Pressing Start energises Motor; the Motor contact then holds the rung on after Start is released; pressing Stop breaks the rung.

![The PLC repeats its scan every few milliseconds; the rung latches the motor on until Stop is pressed.](plc_scan_ladder)

## Safety first

The stop button is wired as a normally closed contact in the field, so a broken wire stops the machine. This is **fail-safe** design. Emergency stops must not rely only on the PLC program: they use hardwired circuits or certified safety relays and safety PLCs, designed to standards such as IEC 62061 and ISO 13849.

## SCADA and HMI

A **HMI** (human-machine interface) is the operator screen at a machine. **SCADA** (supervisory control and data acquisition) links many PLCs and remote sites (pumping stations, substations, pipelines) to a central control room, with alarms, trends and historians that record data over time.

## Industrial networks

- **Modbus** (1979, Modicon) is simple and everywhere. Modbus RTU runs over **RS-485**, a two-wire differential bus that works over about 1200 m with up to 32 standard devices per segment. **Modbus TCP** carries the same messages over Ethernet.
- **PROFINET**, **EtherNet/IP** and **EtherCAT** are industrial Ethernet protocols for fast, deterministic control.
- **OPC UA** is a vendor-neutral standard for exchanging data between PLCs, SCADA and IT systems.

Connecting plants to networks brings **cybersecurity** risks. Segment networks, change default passwords and never expose PLCs directly to the internet.

# Key points
- Closed-loop control measures the output and corrects errors; open loop does not.
- PID: P reacts to present error, I removes steady-state offset, D damps the response.
- A PLC scans: read inputs, run the program, write outputs, repeat every few milliseconds.
- IEC 61131-3 defines PLC languages; ladder logic uses contacts and coils like relay diagrams.
- A seal-in circuit latches a motor on; stop buttons are wired NC so a broken wire is fail-safe.
- Modbus RTU runs over RS-485; Modbus TCP runs over Ethernet.

# Quiz
Q: Which PID term removes the steady-state offset?
- Proportional
* Integral
- Derivative
- None of them
> The integral term keeps adding up the error, so the output keeps changing until the error is zero.

Q: What is the correct order of a PLC scan cycle?
* Read inputs, execute program, write outputs
- Write outputs, read inputs, execute program
- Execute program, read inputs, write outputs
- Read inputs, write outputs, execute program
> The PLC takes a snapshot of the inputs, solves the logic from top to bottom, then updates the outputs.

Q: In a start/stop seal-in circuit, what keeps the motor running after Start is released?
- The stop button contact
* A contact of the motor output wired in parallel with Start
- A timer
- The emergency stop
> The motor's own contact bypasses the Start button, so the rung stays powered until Stop breaks it.

Q: Why is a stop button wired as a normally closed contact?
- It uses less current
- It makes the program shorter
* A broken wire stops the machine instead of leaving it unstoppable
- Normally open buttons are illegal
> With NC wiring, any open circuit reads the same as pressing Stop. This is fail-safe design.

Q: Which physical layer does Modbus RTU commonly use?
- USB
* RS-485
- Wi-Fi
- HDMI
> Modbus RTU typically runs over RS-485, a differential two-wire bus that works over long distances in noisy plants.
