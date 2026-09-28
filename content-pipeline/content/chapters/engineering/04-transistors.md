---
topic: engineering
position: 4
title: Transistors: switches and amplifiers
summary: How bipolar transistors and MOSFETs work, how to use them as switches for relays and motors, and the basics of amplification.
difficulty: 2
sources:
- Wikipedia: Bipolar junction transistor | https://en.wikipedia.org/wiki/Bipolar_junction_transistor
- Wikipedia: MOSFET | https://en.wikipedia.org/wiki/MOSFET
- Wikipedia: Transistor | https://en.wikipedia.org/wiki/Transistor
---
## Why transistors matter

The transistor is a small signal controlling a large one. It was invented at Bell Labs in 1947, and today's processors contain billions of them. In industrial electronics you will mostly use transistors as **switches** (turning relays, solenoids, lamps and motors on and off) and as **amplifiers** (making small sensor signals bigger).

## The bipolar junction transistor (BJT)

A BJT has three terminals: **base**, **collector** and **emitter**. In an NPN transistor, a small current into the base allows a much larger current to flow from collector to emitter. The ratio is the current gain, β (also written h_FE):

> I_C = β × I_B      (β is typically 50 to 300)

The base-emitter junction behaves like a diode, so V_BE ≈ 0.7 V when the transistor conducts. A BJT has three operating regions:

- **Cut-off:** no base current, no collector current. The switch is off.
- **Active:** I_C = β × I_B. Used for amplification.
- **Saturation:** the base is driven so hard that the collector-emitter voltage falls to about 0.2 V. The switch is fully on.

## Designing a BJT switch

Say a 12 V relay coil draws 60 mA and a microcontroller pin gives 5 V. With a minimum β of 100, the base needs at least 0.6 mA. Engineers overdrive the base by a factor of 2 to 5 to guarantee saturation, so aim for about 2 mA:

> R_B = (5 − 0.7) ÷ 0.002 ≈ 2.2 kΩ

Put a flyback diode across the relay coil, and the circuit is complete.

![A microcontroller pin switches a 12 V relay through an NPN transistor, protected by a flyback diode.](transistor_relay)

## The MOSFET

A MOSFET (metal-oxide-semiconductor field-effect transistor) is controlled by **voltage**, not current. Its terminals are **gate**, **drain** and **source**. The gate is insulated by a thin oxide layer, so it draws almost no steady current. When the gate-source voltage V_GS exceeds the threshold, a channel forms and current flows from drain to source.

When fully on, a MOSFET acts like a small resistance, R_DS(on), which can be a few milliohms. The power lost is:

> P = I² × R_DS(on)

At 10 A through 10 mΩ, that is only 1 W. This is why MOSFETs dominate power switching.

Two practical points:

- **Logic-level** MOSFETs are fully on at 4.5 V or even 2.5 V on the gate. Others need 10 V; driving them from 3.3 V leaves them half-on and hot.
- The gate behaves like a capacitor. Fast switching needs a gate driver that can push and pull large current pulses, and a gate resistor tames ringing.

## BJT or MOSFET?

- MOSFETs are better for high current and fast switching (motor drives, switch-mode supplies).
- BJTs are cheap and robust for small loads and analogue amplifiers.
- IGBTs combine a MOSFET gate with bipolar conduction and dominate high-voltage motor drives, as the power electronics chapter explains.

## Amplification

In the active region, a small change in base current produces a proportionally larger change in collector current. With a collector resistor, that becomes a larger voltage swing. The **common-emitter** amplifier is the classic circuit: its voltage gain is roughly R_C ÷ R_E when an emitter resistor is used, which makes the gain predictable despite variation in β. In modern designs most small-signal amplification is done with op-amps, the subject of the next chapter.

## Heat and safe operation

Every transistor has maximum ratings for voltage, current and power, plus a safe operating area. In switching, most heat is produced during the transition between off and on, which is why switching fast (but not too fast for EMI) and using heat sinks matter.

# Key points
- A transistor lets a small signal control a large current; it works as a switch or an amplifier.
- BJT: I_C = β × I_B, V_BE ≈ 0.7 V; saturate it fully when using it as a switch.
- Overdrive the base current by 2-5 times the minimum needed to guarantee saturation.
- MOSFETs are voltage-controlled; conduction loss is I² × R_DS(on).
- Use logic-level MOSFETs when driving from 3.3 V or 5 V logic.

# Quiz
Q: An NPN transistor has β = 150 and a base current of 0.2 mA in the active region. What is the collector current?
- 0.75 mA
* 30 mA
- 150 mA
- 3 mA
> I_C = β × I_B = 150 × 0.2 mA = 30 mA.

Q: What controls the current in a MOSFET?
- The base current
* The gate-source voltage
- The collector voltage
- The drain current alone
> The gate is insulated; the gate-source voltage creates the conducting channel.

Q: A MOSFET with R_DS(on) = 20 mΩ carries 5 A. How much power does it dissipate while on?
- 0.1 W
* 0.5 W
- 5 W
- 100 W
> P = I²R = 25 × 0.02 = 0.5 W.

Q: Why do designers drive a BJT switch with more base current than β suggests?
- To make it switch off faster
* To make sure it is fully saturated despite variation in β
- To increase the collector voltage
- To reduce the load current
> β varies between parts and with temperature. Extra base current keeps the transistor in saturation, where it runs coolest.

Q: A MOSFET needs 10 V on the gate to turn fully on, but it is driven from a 3.3 V microcontroller pin. What is the likely result?
- It works perfectly
* It is only partly on, has high resistance and overheats
- It turns on more quickly
- It is destroyed immediately by the gate voltage
> Below its rated gate voltage, R_DS(on) is much higher, so the device dissipates far more power. Use a logic-level part or a gate driver.
