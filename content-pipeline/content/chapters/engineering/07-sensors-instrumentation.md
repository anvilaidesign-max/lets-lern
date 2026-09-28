---
topic: engineering
position: 7
title: Sensors and instrumentation
summary: 4–20 mA current loops, thermocouples and RTDs, strain gauges and bridges, and how analogue signals become digital values.
difficulty: 3
sources:
- Wikipedia: Current loop | https://en.wikipedia.org/wiki/Current_loop
- Wikipedia: Thermocouple | https://en.wikipedia.org/wiki/Thermocouple
- Wikipedia: Resistance thermometer | https://en.wikipedia.org/wiki/Resistance_thermometer
- Wikipedia: Wheatstone bridge | https://en.wikipedia.org/wiki/Wheatstone_bridge
- Wikipedia: Nyquist–Shannon sampling theorem | https://en.wikipedia.org/wiki/Nyquist%E2%80%93Shannon_sampling_theorem
---
## From the physical world to a number

Instrumentation is the chain that turns a physical quantity (temperature, pressure, flow, level, position) into a number a controller can act on:

- a **sensor** converts the quantity into an electrical change,
- **signal conditioning** amplifies, filters and linearises it,
- a **transmitter** sends it over a robust signal, often 4–20 mA,
- an **ADC** in the PLC or data logger converts it to a digital value.

## The 4–20 mA current loop

The 4–20 mA loop is the most common analogue signal in process plants. The transmitter regulates the loop **current** to represent the measurement: 4 mA is 0 percent of the range and 20 mA is 100 percent.

> Value = LRV + (I − 4) ÷ 16 × (URV − LRV)

For a 0–10 bar pressure transmitter reading 12 mA: (12 − 4) ÷ 16 = 50 percent, so 5 bar.

Why current instead of voltage?

- **Wire resistance does not matter:** the same current flows through the whole series loop, so long cables do not change the reading.
- **Live zero:** 0 percent is 4 mA, not 0 mA. A reading of 0 mA therefore means a broken wire or dead transmitter, which the system can detect. Readings below about 3.6 mA or above about 21 mA are commonly used to flag faults.
- **Noise immunity:** a low-impedance current loop picks up less interference than a high-impedance voltage signal.
- **Two-wire power:** many transmitters take their operating power from the 4 mA baseline, so the same two wires carry power and signal. The HART protocol even superimposes digital data on the same pair.

At the PLC, the loop current usually flows through a 250 Ω resistor, turning 4–20 mA into 1–5 V for the input card.

![The transmitter sets the loop current; the PLC reads it as a voltage across 250 Ω.](current_loop)

## Thermocouples

A **thermocouple** is two different metals joined at one end. A temperature difference between the hot (measuring) junction and the cold (reference) junction produces a small voltage, the **Seebeck effect**: roughly 41 µV per °C for the common **type K** (chromel–alumel), which covers about −200 to +1250 °C. Thermocouples are rugged, cheap and handle very high temperatures, but their signal is tiny, non-linear, and needs **cold junction compensation**: the instrument measures its own terminal temperature and corrects for it. Use the matching extension cable, or you create extra junctions and errors.

## RTDs

A **resistance temperature detector** uses a metal (usually platinum) whose resistance rises predictably with temperature. The standard **Pt100** has 100 Ω at 0 °C and rises by about 0.385 Ω per °C, so it reads about 138.5 Ω at 100 °C. RTDs are more accurate and stable than thermocouples but have a narrower range (typically up to about 600 °C). Because lead resistance adds error, 3-wire and 4-wire connections are used to cancel it.

## Strain gauges and the Wheatstone bridge

A **strain gauge** is a thin foil pattern whose resistance changes slightly when stretched. Load cells in weighing scales use them. The change is tiny, a fraction of a percent, so gauges are placed in a **Wheatstone bridge**: four resistances arranged so the output is zero when balanced and a small differential voltage appears when one changes. An instrumentation amplifier then amplifies that millivolt signal.

## Analogue to digital conversion

An **ADC** with n bits divides its input range into 2ⁿ steps. The smallest step, the resolution, is:

> Resolution = Range ÷ 2ⁿ

A 12-bit ADC on a 0–10 V range has 4096 steps of about 2.44 mV. A 16-bit converter has 65,536 steps.

How often you sample matters too. The **Nyquist–Shannon sampling theorem** says you must sample at more than twice the highest frequency present, or high-frequency content will fold down and appear as false low frequencies (**aliasing**). That is why an analogue **anti-aliasing filter** sits before the ADC.

## Noise, shielding and grounding

- Use **twisted pair** cable for signals, so induced noise cancels.
- Use **shielded** cable and ground the shield at **one end** only, usually the control panel, to avoid ground loops.
- Keep signal cables away from motor and power cables, and cross them at right angles.
- Where grounds differ, use **isolated** inputs or signal isolators.

# Key points
- 4–20 mA: 4 mA = 0%, 20 mA = 100%; 12 mA = 50%. The live zero lets systems detect broken wires.
- Current loops ignore cable resistance and resist noise; many transmitters are loop-powered on two wires.
- Thermocouples use the Seebeck effect and need cold junction compensation; type K gives about 41 µV/°C.
- A Pt100 RTD is 100 Ω at 0 °C and rises about 0.385 Ω/°C; use 3- or 4-wire connections.
- ADC resolution = range/2ⁿ; sample above twice the highest frequency to avoid aliasing.
- Ground cable shields at one end only to avoid ground loops.

# Quiz
Q: A 0–200 °C temperature transmitter outputs 8 mA. What temperature does this represent?
- 40 °C
* 50 °C
- 80 °C
- 100 °C
> (8 − 4) ÷ 16 = 25% of 200 °C = 50 °C.

Q: A 4–20 mA input reads 0 mA. What is the most likely cause?
- The process is at 0%
* A broken wire or a failed transmitter
- The process is at 100%
- The ADC resolution is too low
> 0% is 4 mA. A true zero current means no current is flowing at all, which points to an open circuit or a dead transmitter.

Q: What is the approximate resistance of a Pt100 sensor at 50 °C?
- 50 Ω
- 100 Ω
* About 119 Ω
- About 150 Ω
> 100 + 50 × 0.385 ≈ 119.3 Ω.

Q: What is the resolution of a 10-bit ADC measuring 0–5 V?
- 0.5 V
* About 4.9 mV
- About 1.2 mV
- 10 mV
> 5 V ÷ 2¹⁰ = 5 ÷ 1024 ≈ 4.88 mV.

Q: A vibration signal contains frequencies up to 2 kHz. What is the minimum sampling rate to avoid aliasing?
- 1 kHz
- 2 kHz
* More than 4 kHz
- 20 kHz exactly
> Nyquist requires sampling at more than twice the highest frequency: above 4 kHz. In practice engineers sample several times higher.
