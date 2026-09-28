---
topic: engineering
position: 2
title: AC circuits, reactance and power factor
summary: Sine waves, RMS values, how capacitors and inductors behave with AC, impedance, and why power factor matters in industry.
difficulty: 2
sources:
- Wikipedia: Alternating current | https://en.wikipedia.org/wiki/Alternating_current
- Wikipedia: Electrical reactance | https://en.wikipedia.org/wiki/Electrical_reactance
- Wikipedia: Power factor | https://en.wikipedia.org/wiki/Power_factor
- Wikipedia: Three-phase electric power | https://en.wikipedia.org/wiki/Three-phase_electric_power
---
## Why AC?

Almost all mains power is alternating current (AC): the voltage swings back and forth as a sine wave. AC won out over DC for power distribution because transformers can raise it to high voltage for efficient long-distance transmission, then lower it again for use. Zimbabwe, South Africa and most of the world use 50 Hz; North America uses 60 Hz.

## Describing a sine wave

A sine wave has an amplitude (peak value), a frequency f in hertz (cycles per second) and a phase. The period is T = 1/f, so a 50 Hz supply repeats every 20 ms. Engineers often use angular frequency:

> ω = 2πf      (for 50 Hz, ω ≈ 314 rad/s)

## RMS values

The **RMS** (root mean square) value of an AC voltage is the DC voltage that would deliver the same heating power into a resistor. For a pure sine wave:

> V_rms = V_peak ÷ √2 ≈ 0.707 × V_peak

When we say mains is "230 V", we mean 230 V RMS. Its peak is 230 × √2 ≈ 325 V, which is why insulation and component ratings must be chosen for the peak, not the RMS value.

## Capacitors and inductors with AC

A capacitor stores energy in an electric field; an inductor stores it in a magnetic field. With AC, both oppose current in a way that depends on frequency. This opposition is called **reactance** (X, in ohms):

> Capacitor: X_C = 1 ÷ (2πfC)      Inductor: X_L = 2πfL

A capacitor passes high frequencies easily and blocks DC (X_C is infinite at f = 0). An inductor does the opposite: it passes DC and resists fast changes. This is the basis of filters: a series inductor and shunt capacitor form a low-pass filter, used to smooth power supplies and remove noise.

Reactance also shifts timing. In a pure capacitor, current leads voltage by 90°; in a pure inductor, current lags voltage by 90°.

## Impedance

Real circuits mix resistance and reactance. The total opposition is the **impedance** Z. For a resistor and inductor in series:

> |Z| = √(R² + X_L²)      phase angle φ = arctan(X_L ÷ R)

Example: R = 30 Ω and X_L = 40 Ω give |Z| = √(900 + 1600) = 50 Ω. On 230 V this draws 230 ÷ 50 = 4.6 A, with current lagging voltage by about 53°.

## Real, reactive and apparent power

With a phase shift, not all current does useful work. Engineers separate three kinds of power:

- **Real power** P (watts, W): energy actually converted to heat, light or motion.
- **Reactive power** Q (volt-ampere reactive, var): energy that sloshes back and forth between the source and the fields of inductors and capacitors each cycle.
- **Apparent power** S (volt-amperes, VA): the product V_rms × I_rms that cables and transformers must carry.

> S² = P² + Q²      Power factor = P ÷ S = cos φ (for sine waves)

![A sine wave's peak and RMS values, and the power triangle linking real, reactive and apparent power.](ac_sine_power)

## Why power factor matters

Induction motors, transformers and fluorescent ballasts are inductive, so industrial plants often have a lagging power factor such as 0.7. That means the supply must deliver more current than the real power needs: more copper losses, bigger cables, and often penalty charges from the utility. The usual fix is **power factor correction**: banks of capacitors connected in parallel supply the reactive current locally, bringing the power factor close to 1.

Power factor cannot exceed 1, because real power can never be greater than apparent power.

## Three-phase power

Industry runs on three-phase supplies: three sine waves 120° apart. Three-phase delivers constant total power (smooth torque in motors) and needs less conductor material than single-phase for the same power. In a star (wye) connection:

> V_line = √3 × V_phase      (400 V line-to-line ≈ √3 × 230 V phase)

and the power of a balanced load is P = √3 × V_line × I_line × cos φ.

# Key points
- Mains is AC because transformers make high-voltage transmission efficient; southern Africa uses 50 Hz.
- V_rms = V_peak/√2 for a sine wave; 230 V RMS has a peak of about 325 V.
- X_C = 1/(2πfC) falls with frequency; X_L = 2πfL rises with frequency.
- Impedance combines resistance and reactance; |Z| = √(R² + X²) for series R and X.
- Power factor = P/S = cos φ; capacitor banks correct lagging, inductive loads.
- In a star three-phase system, line voltage is √3 times phase voltage.

# Quiz
Q: What is the peak voltage of a 230 V RMS sine wave?
- 163 V
- 230 V
* About 325 V
- 460 V
> V_peak = V_rms × √2 = 230 × 1.414 ≈ 325 V.

Q: What happens to a capacitor's reactance as frequency increases?
* It decreases
- It increases
- It stays the same
- It becomes negative resistance
> X_C = 1/(2πfC), so doubling the frequency halves the reactance. Capacitors pass high frequencies.

Q: A series circuit has R = 6 Ω and X_L = 8 Ω. What is the impedance magnitude?
- 14 Ω
- 2 Ω
* 10 Ω
- 48 Ω
> |Z| = √(6² + 8²) = √(36 + 64) = √100 = 10 Ω.

Q: A factory load draws 100 kVA at a power factor of 0.8. What is its real power?
- 125 kW
* 80 kW
- 100 kW
- 60 kW
> P = S × power factor = 100 × 0.8 = 80 kW.

Q: How is a lagging power factor usually corrected in a plant?
- Adding series resistors
- Adding more induction motors
* Adding capacitor banks in parallel with the load
- Raising the supply frequency
> Capacitors supply the reactive current that inductive loads need, so less of it has to come from the grid.
