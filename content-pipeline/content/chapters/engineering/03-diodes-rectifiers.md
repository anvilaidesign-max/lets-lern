---
topic: engineering
position: 3
title: Semiconductors, diodes and power supplies
summary: How doping creates the PN junction, how diodes, LEDs and Zeners behave, and how a rectifier and capacitor turn AC into smooth DC.
difficulty: 2
sources:
- Wikipedia: p–n junction | https://en.wikipedia.org/wiki/P%E2%80%93n_junction
- Wikipedia: Diode | https://en.wikipedia.org/wiki/Diode
- Wikipedia: Rectifier | https://en.wikipedia.org/wiki/Rectifier
- Wikipedia: Zener diode | https://en.wikipedia.org/wiki/Zener_diode
---
## Semiconductors and doping

Silicon has four outer electrons and forms a crystal where every electron is locked in a bond, so pure silicon conducts poorly. **Doping** changes that. Adding a small amount of an element with five outer electrons (such as phosphorus) leaves spare electrons free to move: this is **N-type** silicon. Adding an element with three (such as boron) leaves "holes", missing electrons that behave like positive charges: this is **P-type** silicon.

## The PN junction

Where P-type and N-type meet, electrons and holes near the boundary recombine, leaving a thin **depletion region** with no free carriers and a built-in voltage across it. This junction is the heart of diodes, transistors and solar cells.

- **Forward bias** (P side positive): the external voltage overcomes the built-in barrier and current flows. For silicon this needs about 0.6 to 0.7 V.
- **Reverse bias** (P side negative): the depletion region widens and only a tiny leakage current flows, until the breakdown voltage is reached.

A diode is therefore a one-way valve for current: current flows from anode to cathode, and the band on the package marks the cathode.

## Types of diode

- **Rectifier diodes** (such as the 1N4007) handle mains-frequency currents and high reverse voltages.
- **Schottky diodes** use a metal-semiconductor junction, with a lower forward drop (around 0.2 to 0.4 V) and very fast switching. They are common in switch-mode supplies.
- **LEDs** emit light when forward biased. Their forward voltage depends on colour (roughly 1.8 V for red to about 3 V for blue and white) and they always need current limiting.
- **Zener diodes** are designed to operate in reverse breakdown at a precise voltage, which makes them simple voltage references and clamps.

## Current-limiting an LED

An LED has almost no resistance once it conducts, so a series resistor sets the current:

> R = (V_supply − V_LED) ÷ I_LED

For a red LED (2 V) at 15 mA from 12 V: R = (12 − 2) ÷ 0.015 ≈ 667 Ω, so use the next standard value, 680 Ω. Its power is 0.015² × 680 ≈ 0.15 W.

## From AC to DC: rectifiers

Electronics needs DC, but the mains is AC. A **rectifier** uses diodes to make current flow one way:

- **Half-wave:** one diode passes only the positive half-cycles. It is simple but wasteful, and the ripple is at 50 Hz.
- **Full-wave bridge:** four diodes route both half-cycles in the same direction. Output pulses at 100 Hz, and two diodes conduct at a time, so about 1.4 V is lost to diode drops.

![Four diodes steer both half-cycles the same way; the capacitor smooths the pulses into DC.](bridge_rectifier)

## Smoothing and ripple

A large capacitor after the rectifier charges near the peak and supplies the load between peaks. The remaining variation is **ripple**. A good estimate for a full-wave rectifier is:

> V_ripple ≈ I_load ÷ (2 × f × C)

With 1 A, 50 Hz and 4700 µF: V_ripple ≈ 1 ÷ (2 × 50 × 0.0047) ≈ 2.1 V peak to peak. Doubling the capacitance halves the ripple.

## Regulation

A linear regulator (such as the 7805) or a Zener stage then holds the output steady despite ripple and load changes. A linear regulator burns the extra voltage as heat: dropping 12 V to 5 V at 1 A wastes 7 W. Switch-mode regulators avoid most of that loss, as you will see in the power electronics chapter.

## Protection diodes

Diodes also protect circuits. A **flyback diode** across a relay coil gives the coil's stored energy a safe path when the transistor switches off, preventing a voltage spike that would destroy the transistor. A diode in series with a supply input protects against reverse polarity.

# Key points
- Doping makes N-type (spare electrons) and P-type (holes) silicon; their junction forms a depletion region.
- A silicon diode conducts forward above about 0.6-0.7 V and blocks reverse voltage until breakdown.
- LEDs need a series resistor: R = (V_supply − V_LED)/I.
- A bridge rectifier uses four diodes, gives 100 Hz ripple on 50 Hz mains and drops about 1.4 V.
- Ripple ≈ I/(2fC) for full-wave; bigger capacitors mean less ripple.
- Put a flyback diode across relay coils to protect the switching transistor.

# Quiz
Q: What is added to silicon to make N-type material?
* An element with five outer electrons, such as phosphorus
- An element with three outer electrons, such as boron
- Extra silicon atoms
- Oxygen
> Phosphorus has one more outer electron than silicon, and that spare electron is free to carry current.

Q: A 5 V supply drives a blue LED (3 V) at 20 mA. What series resistor is needed?
- 250 Ω
* 100 Ω
- 150 Ω
- 40 Ω
> R = (5 − 3) ÷ 0.02 = 2 ÷ 0.02 = 100 Ω.

Q: What is the ripple frequency after a full-wave bridge on 50 Hz mains?
- 25 Hz
- 50 Hz
* 100 Hz
- 200 Hz
> A bridge flips the negative half-cycles, so there are two pulses per cycle: 2 × 50 = 100 Hz.

Q: A full-wave supply feeds 0.5 A into a 2200 µF capacitor at 50 Hz. What is the approximate ripple?
- 0.23 V
* About 2.3 V
- 23 V
- 11 V
> V_ripple ≈ I ÷ (2fC) = 0.5 ÷ (2 × 50 × 0.0022) = 0.5 ÷ 0.22 ≈ 2.3 V.

Q: Why is a diode placed across a relay coil?
- To make the relay switch faster
- To reduce the coil current
* To absorb the voltage spike when the coil is switched off
- To convert AC to DC for the coil
> An inductor resists sudden changes in current. The flyback diode gives the coil current a safe path, so no damaging spike appears across the transistor.
