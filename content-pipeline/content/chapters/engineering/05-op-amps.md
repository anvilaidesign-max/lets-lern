---
topic: engineering
position: 5
title: Operational amplifiers
summary: The ideal op-amp rules, inverting and non-inverting amplifiers, followers, comparators and how op-amps condition sensor signals.
difficulty: 2
sources:
- Wikipedia: Operational amplifier | https://en.wikipedia.org/wiki/Operational_amplifier
- Wikipedia: Operational amplifier applications | https://en.wikipedia.org/wiki/Operational_amplifier_applications
- Wikipedia: Instrumentation amplifier | https://en.wikipedia.org/wiki/Instrumentation_amplifier
---
## What an op-amp is

An operational amplifier is a high-gain differential amplifier in a small package. It has two inputs, **non-inverting (+)** and **inverting (−)**, and one output. The output is the difference between the inputs multiplied by a very large open-loop gain, often 100,000 or more. On its own that gain is far too high to use; the magic comes from **negative feedback**, which trades gain for precision.

## The ideal op-amp rules

With negative feedback (output connected back to the − input), two golden rules let you analyse most circuits:

- **Rule 1:** the output does whatever it takes to make the voltage difference between the inputs zero, so V+ = V−.
- **Rule 2:** no current flows into the inputs.

Real op-amps approximate these rules well as long as the output stays within its supply limits.

## The inverting amplifier

The input signal goes through R_in into the − input; R_f connects the output back to the − input; the + input is grounded. Because V− = V+ = 0 V (a "virtual ground"), the current through R_in must all flow through R_f:

> Gain = V_out ÷ V_in = −R_f ÷ R_in

With R_in = 10 kΩ and R_f = 100 kΩ, the gain is −10: a 0.2 V input gives −2 V out. The minus sign means the output is inverted.

![The inverting amplifier: R_f and R_in set the gain, and the − input sits at a virtual ground.](inverting_amplifier)

## The non-inverting amplifier

The signal goes to the + input; a divider of R_f and R_g feeds the output back to the − input:

> Gain = 1 + R_f ÷ R_g

With R_f = 90 kΩ and R_g = 10 kΩ, the gain is 10, and the output is in phase with the input. This circuit also has a very high input impedance, so it hardly loads the sensor.

## The voltage follower

Connect the output straight to the − input and feed the signal to the + input: the gain is exactly 1. That sounds useless, but it isn't. The follower (buffer) has a very high input impedance and a low output impedance, so it can take a weak signal, such as a voltage divider or a high-impedance sensor, and drive a load without changing it.

## Summing and difference amplifiers

Several inputs, each through its own resistor into the virtual ground, add together: this is the summing amplifier used in audio mixers and simple DACs. A difference amplifier outputs the difference of two voltages, which is the basis of measuring bridge sensors.

## Instrumentation amplifiers

Sensors like strain gauges produce tiny differential signals (millivolts) riding on large common-mode voltages and noise. An **instrumentation amplifier** (three op-amps in one package, such as the INA128) amplifies the difference precisely, rejects what is common to both inputs, and sets its gain with a single resistor. Its ability to ignore common signals is measured by the **common-mode rejection ratio (CMRR)**.

## The comparator

Without negative feedback, the huge gain makes the output slam to one supply rail or the other depending on which input is higher. This is a **comparator**: it turns an analogue level into an on/off signal, as in a thermostat or a low-battery alarm. Adding a little positive feedback creates **hysteresis** (a Schmitt trigger) so the output does not chatter when the input is noisy and close to the threshold.

## Real-world limits

- **Output swing:** the output cannot exceed the supply rails. "Rail-to-rail" op-amps get close to them.
- **Bandwidth:** gain falls at high frequency. The gain-bandwidth product is roughly constant: a 1 MHz op-amp at a gain of 10 has about 100 kHz of bandwidth.
- **Slew rate:** the maximum rate the output can change, in V/µs. Large, fast signals can be distorted by it.
- **Offset voltage:** a small built-in error, amplified along with the signal.

# Key points
- With negative feedback: V+ = V− and no current flows into the inputs.
- Inverting gain = −R_f/R_in; non-inverting gain = 1 + R_f/R_g.
- A voltage follower (gain 1) buffers weak signals without loading them.
- Instrumentation amplifiers boost small differential sensor signals and reject common-mode noise.
- Without feedback, an op-amp works as a comparator; hysteresis stops chatter.
- Gain-bandwidth product and slew rate limit speed.

# Quiz
Q: An inverting amplifier has R_in = 4.7 kΩ and R_f = 47 kΩ. What is its gain?
- +10
* −10
- +11
- −0.1
> Gain = −R_f/R_in = −47/4.7 = −10.

Q: A non-inverting amplifier has R_f = 20 kΩ and R_g = 5 kΩ. What is its gain?
- 4
* 5
- −4
- 25
> Gain = 1 + R_f/R_g = 1 + 20/5 = 5.

Q: Why is a voltage follower useful if its gain is only 1?
- It doubles the signal power
* It has a high input impedance and low output impedance, so it buffers weak signals
- It inverts the signal
- It removes noise completely
> The follower draws almost no current from the source but can drive a load, so the source voltage is not pulled down.

Q: What does a comparator with hysteresis prevent?
- The output reaching the supply rails
* Rapid on/off chattering when a noisy input is near the threshold
- Any current flowing into the inputs
- The need for a power supply
> Hysteresis gives two slightly different switching thresholds, so small noise cannot flip the output back and forth.

Q: An op-amp has a gain-bandwidth product of 2 MHz and is set to a gain of 20. Roughly what bandwidth remains?
- 2 MHz
- 40 MHz
* 100 kHz
- 20 kHz
> Bandwidth ≈ GBW ÷ gain = 2,000,000 ÷ 20 = 100 kHz.
