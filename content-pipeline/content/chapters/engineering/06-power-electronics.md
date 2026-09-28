---
topic: engineering
position: 6
title: Power electronics: thyristors, converters and motor drives
summary: SCRs, TRIACs and IGBTs, how buck converters and inverters use fast switching, and how a variable frequency drive controls motor speed.
difficulty: 3
sources:
- Wikipedia: Power electronics | https://en.wikipedia.org/wiki/Power_electronics
- Wikipedia: Silicon controlled rectifier | https://en.wikipedia.org/wiki/Silicon_controlled_rectifier
- Wikipedia: Buck converter | https://en.wikipedia.org/wiki/Buck_converter
- Wikipedia: Variable-frequency drive | https://en.wikipedia.org/wiki/Variable-frequency_drive
- Wikipedia: Induction motor | https://en.wikipedia.org/wiki/Induction_motor
---
## Switching instead of burning

Power electronics converts electrical energy from one form to another: AC to DC, DC to DC at a different voltage, DC to AC at a chosen frequency. The key idea is to use semiconductors as **switches**, not as variable resistors. A switch that is fully on (low voltage across it) or fully off (no current through it) dissipates very little power, so converters can reach efficiencies of 90 to 98 percent. A linear regulator dropping 24 V to 12 V, by contrast, throws half the energy away as heat.

## Thyristors: the SCR and TRIAC

The **silicon controlled rectifier (SCR)** is a four-layer device with anode, cathode and gate. A short gate pulse turns it on, and then it **latches**: it stays on without gate current until the current through it falls below the holding current. On AC this happens naturally at every zero crossing.

By delaying the gate pulse after each zero crossing (the **firing angle**), you control how much of each half-cycle reaches the load. This **phase control** runs heaters, lamp dimmers and controlled rectifiers for DC motors. A **TRIAC** is effectively two SCRs back to back, conducting in both directions, which is why it appears in household dimmers and fan speed controls.

## IGBTs and MOSFETs

The **IGBT** (insulated-gate bipolar transistor) combines a MOSFET's easy voltage-controlled gate with bipolar conduction that handles high voltage and current. Unlike an SCR, it can be turned **off** by the gate at any time. IGBTs dominate motor drives, inverters and traction from roughly 600 V upwards; MOSFETs rule at lower voltages and higher switching frequencies. Newer wide-bandgap devices made of silicon carbide (SiC) and gallium nitride (GaN) switch faster with lower losses, and are spreading through electric vehicles and chargers.

## The buck converter

A buck converter steps DC voltage down efficiently. A switch chops the input on and off at high frequency (tens of kHz to MHz); an inductor and capacitor smooth the pulses. For the ideal converter in continuous conduction:

> V_out = D × V_in      where D is the duty cycle (fraction of time the switch is on)

To get 5 V from 24 V, D ≈ 5 ÷ 24 ≈ 21 percent. Because energy is (nearly) conserved, the output current is higher than the input current: a buck converter delivering 5 V at 2 A draws only about 0.45 A from 24 V at 95 percent efficiency. The **boost** converter does the opposite, stepping voltage up: ideally V_out = V_in ÷ (1 − D).

## Inverters and PWM

An **inverter** makes AC from DC. An H-bridge (for single phase) or a six-switch bridge (for three phase) switches the DC bus rapidly using **pulse-width modulation (PWM)**: the pulse widths are varied in a sine pattern, and the motor's inductance filters the current into a close approximation of a sine wave. Solar inverters, UPS systems and motor drives all work this way.

## Induction motors and the VFD

The three-phase induction motor is the workhorse of industry: pumps, fans, conveyors and compressors. Its speed is tied to the supply frequency. The rotating magnetic field turns at the **synchronous speed**:

> n_s = 120 × f ÷ p      (rpm, where p is the number of poles)

A 4-pole motor on 50 Hz has n_s = 120 × 50 ÷ 4 = 1500 rpm. The rotor runs slightly slower (for example 1450 rpm); the difference is called **slip**, and it is what induces rotor current and torque.

A **variable frequency drive (VFD)** rectifies the mains to a DC bus, then inverts it to a new frequency and voltage. Lowering frequency lowers speed. To keep the motor's magnetic flux constant, the drive keeps the voltage-to-frequency ratio roughly constant (**V/f control**); more advanced drives use vector control for precise torque.

Why it matters: for centrifugal pumps and fans, power rises roughly with the cube of speed (the affinity laws). Running a fan at 80 percent speed needs only about 0.8³ ≈ 51 percent of the power. Replacing a throttling valve with a VFD is one of the biggest energy savings in industry.

![A VFD rectifies the mains, stores energy on a DC bus, then rebuilds AC at any frequency to set motor speed.](vfd_block)

## Practical concerns

- **Heat:** switching and conduction losses must be removed with heat sinks and airflow.
- **EMI:** fast-switching edges radiate noise. Use shielded motor cables, proper grounding and filters.
- **Harmonics:** rectifier front ends draw non-sinusoidal current that can disturb the supply. Line reactors and active front ends reduce it.
- **Safety:** DC bus capacitors in drives can hold lethal voltage for minutes after power is removed. Wait the rated time and measure before touching.

# Key points
- Power electronics uses semiconductors as fast switches, reaching 90-98% efficiency.
- An SCR latches on after a gate pulse and turns off when current falls below the holding current; phase control varies the firing angle.
- IGBTs can be switched off by the gate and dominate high-voltage motor drives.
- Buck converter: V_out = D × V_in; boost: V_out = V_in/(1 − D).
- Synchronous speed n_s = 120f/p; a VFD changes frequency (with V/f roughly constant) to change speed.
- Fan and pump power falls roughly with the cube of speed, so VFDs save a lot of energy.

# Quiz
Q: What turns off a conducting SCR on an AC supply?
- Removing the gate signal
- Applying a gate pulse
* The current falling below the holding current, as at a zero crossing
- The load becoming hotter
> An SCR latches on. It only turns off when its current drops below the holding current, which happens naturally each half-cycle on AC.

Q: An ideal buck converter has 48 V in and a 25% duty cycle. What is the output voltage?
- 36 V
* 12 V
- 25 V
- 64 V
> V_out = D × V_in = 0.25 × 48 = 12 V.

Q: What is the synchronous speed of a 6-pole induction motor on 50 Hz?
- 1500 rpm
- 3000 rpm
* 1000 rpm
- 750 rpm
> n_s = 120 × 50 ÷ 6 = 1000 rpm.

Q: Why does a VFD keep the voltage-to-frequency ratio roughly constant?
- To make the motor run faster than synchronous speed
* To keep the motor's magnetic flux, and so its torque capability, constant
- To increase slip
- To stop the DC bus charging
> Flux is proportional to V/f. Lowering frequency without lowering voltage would saturate the motor and cause overheating.

Q: A fan's speed is reduced to half using a VFD. Roughly how much power does it need now?
- Half
- A quarter
* About one eighth
- The same
> By the affinity laws, power scales with the cube of speed: 0.5³ = 0.125.
