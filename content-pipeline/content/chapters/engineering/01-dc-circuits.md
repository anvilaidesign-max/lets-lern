---
topic: engineering
position: 1
title: DC circuits: voltage, current and resistance
summary: The three quantities behind every circuit, Ohm's law, power, and how Kirchhoff's laws let you solve any DC network.
difficulty: 1
sources:
- Wikipedia: Ohm's law | https://en.wikipedia.org/wiki/Ohm%27s_law
- Wikipedia: Kirchhoff's circuit laws | https://en.wikipedia.org/wiki/Kirchhoff%27s_circuit_laws
- Wikipedia: Voltage divider | https://en.wikipedia.org/wiki/Voltage_divider
---
## The three quantities

Every electrical circuit is described by three quantities. **Voltage** (V, measured in volts) is the electrical "pressure": the energy each coulomb of charge gains or loses between two points. **Current** (I, in amperes) is the rate at which charge flows: 1 A is one coulomb per second. **Resistance** (R, in ohms, Ω) is how strongly a component opposes current.

A useful picture is water in a pipe: voltage is the pressure difference, current is the flow rate, and resistance is a narrow section of pipe. The picture breaks down eventually, but it is good enough to start.

## Ohm's law

For a resistor, voltage and current are proportional. This is Ohm's law:

> V = I × R      so      I = V ÷ R      and      R = V ÷ I

Example: a 12 V supply across a 470 Ω resistor drives I = 12 ÷ 470 ≈ 0.0255 A, or 25.5 mA. If you measure 3.3 V across a resistor carrying 10 mA, its resistance is 3.3 ÷ 0.010 = 330 Ω.

Ohm's law holds for resistors at a steady temperature. Diodes, lamps and transistors are not "ohmic": their current does not rise in proportion to voltage.

![A 12 V battery drives current through a 470 Ω resistor. The triangle helps you rearrange Ohm's law.](ohms_law_circuit)

## Power

Power is the rate of energy transfer, in watts (W). In a DC circuit:

> P = V × I = I² × R = V² ÷ R

The 470 Ω resistor above dissipates P = 12² ÷ 470 ≈ 0.31 W. A standard 0.25 W resistor would overheat, so you would choose a 0.5 W part. Always check power ratings: most component failures in real equipment are thermal.

## Series and parallel

Resistors in **series** carry the same current, and their resistances add:

> R_total = R1 + R2 + R3 ...

Resistors in **parallel** share the same voltage, and their conductances (1/R) add:

> 1/R_total = 1/R1 + 1/R2 + ...      For two resistors: R_total = (R1 × R2) ÷ (R1 + R2)

Two 1 kΩ resistors in parallel give 500 Ω. A parallel combination is always smaller than its smallest resistor, which is a quick way to check your arithmetic.

## Kirchhoff's laws

Two conservation laws let you solve any DC network:

- **Kirchhoff's current law (KCL):** the currents flowing into a node equal the currents flowing out. Charge does not pile up in a wire.
- **Kirchhoff's voltage law (KVL):** around any closed loop, the voltage rises and drops add to zero. Energy is conserved.

With KCL and KVL you can write one equation per unknown and solve them together. This is the basis of nodal and mesh analysis, which circuit simulators such as SPICE use.

## The voltage divider

Two resistors in series across a supply produce a fraction of the supply voltage at their junction:

> V_out = V_in × R2 ÷ (R1 + R2)

With V_in = 12 V, R1 = 10 kΩ and R2 = 5 kΩ, V_out = 12 × 5 ÷ 15 = 4 V. Dividers set reference voltages and scale sensor signals down to what an ADC can accept.

One catch: the formula assumes no current is drawn from the output. If you connect a load, it appears in parallel with R2 and pulls V_out down. That is why dividers feed high-impedance inputs, or a buffer amplifier, rather than power a load directly.

## Measuring safely

A voltmeter goes **across** a component (in parallel) and has a very high resistance. An ammeter goes **in series** and has a very low resistance, so connecting an ammeter across a supply is effectively a short circuit. It is the classic way to blow a meter's fuse.

# Key points
- Voltage is energy per charge (V), current is charge flow (A), resistance opposes current (Ω).
- Ohm's law: V = I × R. Power: P = V × I = I²R = V²/R.
- Series resistances add; parallel combinations are smaller than the smallest resistor.
- KCL: current into a node equals current out. KVL: voltages around a loop sum to zero.
- A voltage divider gives V_in × R2/(R1 + R2), but only with no load on its output.

# Quiz
Q: A 24 V supply is connected across a 1.2 kΩ resistor. What current flows?
- 2 A
* 20 mA
- 200 mA
- 28.8 A
> I = V/R = 24 ÷ 1200 = 0.02 A = 20 mA.

Q: What is the combined resistance of 6 kΩ and 3 kΩ in parallel?
- 9 kΩ
- 4.5 kΩ
* 2 kΩ
- 18 kΩ
> (6 × 3) ÷ (6 + 3) = 18 ÷ 9 = 2 kΩ, which is less than the smaller 3 kΩ, as expected.

Q: A 100 Ω resistor carries 0.2 A. How much power does it dissipate?
- 20 W
* 4 W
- 0.4 W
- 2 W
> P = I²R = 0.2² × 100 = 0.04 × 100 = 4 W.

Q: Kirchhoff's voltage law is a statement of which principle?
- Conservation of charge
* Conservation of energy
- Conservation of momentum
- Ohm's law
> Around a closed loop the energy gained by charge equals the energy it loses, so voltages sum to zero. KCL is the one based on conservation of charge.

Q: A divider has R1 = 30 kΩ (top) and R2 = 10 kΩ (bottom) on a 12 V supply. What is V_out with no load?
- 9 V
- 4 V
* 3 V
- 6 V
> V_out = 12 × 10 ÷ (30 + 10) = 12 × 0.25 = 3 V.
