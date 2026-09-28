---
topic: math
position: 2
title: Calculus I: rates of change and derivatives
summary: What a derivative means, the rules that make it quick to find, and how derivatives find maximums, minimums and rates in engineering.
difficulty: 2
sources:
- Wikipedia: Derivative | https://en.wikipedia.org/wiki/Derivative
- Wikipedia: Chain rule | https://en.wikipedia.org/wiki/Chain_rule
- Wikipedia: Maximum and minimum | https://en.wikipedia.org/wiki/Maximum_and_minimum
---
## Why calculus?

Calculus is the mathematics of change. It was developed independently by Isaac Newton and Gottfried Wilhelm Leibniz in the late 1600s. **Differential calculus** asks how fast something is changing at an instant; **integral calculus** (next chapter) adds up small pieces to find totals.

## From average to instantaneous rate

If a car travels 120 km in 2 hours, its average speed is 60 km/h. But the speedometer shows the speed at this instant. To get it, take the average over a shorter and shorter interval. The **derivative** is that limit:

> f′(x) = lim (h → 0) of [f(x + h) − f(x)] ÷ h

Geometrically, the derivative is the **gradient of the tangent** to the curve at a point. Leibniz's notation dy/dx reminds you it is a ratio of tiny changes.

## The rules

You rarely use the limit directly. A few rules cover most cases:

- **Power rule:** d/dx (xⁿ) = n·xⁿ⁻¹. So d/dx (x³) = 3x².
- **Constants:** d/dx (5) = 0, and d/dx (k·f) = k·f′.
- **Sum rule:** differentiate term by term.
- **Exponentials and trig:** d/dx (eˣ) = eˣ; d/dx (sin x) = cos x; d/dx (cos x) = −sin x (with x in radians).
- **Product rule:** d/dx (uv) = u′v + uv′.
- **Chain rule** (a function inside a function): d/dx f(g(x)) = f′(g(x)) × g′(x).

Example with the chain rule: d/dx sin(3x) = cos(3x) × 3 = 3cos(3x).

Example with the product rule: d/dx (x² eˣ) = 2x·eˣ + x²·eˣ.

![The derivative at a point is the slope of the tangent line touching the curve there.](derivative_tangent)

## Derivatives in electronics

Circuits are full of rates of change:

> Capacitor current: i = C × dv/dt      Inductor voltage: v = L × di/dt

A capacitor's current depends on how fast its voltage changes, which is why it blocks steady DC. An inductor's voltage depends on how fast its current changes. Try to stop the current instantly and di/dt is enormous, which is exactly why relay coils produce voltage spikes.

For a sine wave v = V sin(ωt), the capacitor current is i = C·V·ω·cos(ωt). The current is a cosine (a 90° lead), and its size grows with ω, which is where X_C = 1/(ωC) comes from.

## Finding maximums and minimums

At a peak or a trough of a smooth curve, the tangent is flat, so the derivative is zero. To find the best value of something:

- write it as a function,
- differentiate and set the derivative to zero,
- check whether each solution is a maximum or a minimum (the second derivative is negative at a maximum and positive at a minimum).

**Example (maximum power transfer):** a source with internal resistance r delivers power P = V²R ÷ (R + r)² to a load R. Setting dP/dR = 0 gives R = r. A load matched to the source resistance receives the maximum power, a result used in radio, audio and solar charge controllers (maximum power point tracking works on the same idea).

**Example (fencing):** with 100 m of fence for a rectangle, the area is A = x(50 − x). dA/dx = 50 − 2x = 0 gives x = 25 m: a square encloses the most area.

## Rates in the real world

Derivatives also connect related quantities. Velocity is the derivative of position, and acceleration is the derivative of velocity. In control systems, the D term of a PID controller responds to the derivative of the error, anticipating where the process is heading.

# Key points
- The derivative is the instantaneous rate of change: the gradient of the tangent.
- Power rule: d/dx xⁿ = n·xⁿ⁻¹; d/dx eˣ = eˣ; d/dx sin x = cos x.
- Product rule: (uv)′ = u′v + uv′; chain rule: f(g(x))′ = f′(g(x))·g′(x).
- Capacitor: i = C·dv/dt; inductor: v = L·di/dt.
- Set the derivative to zero to find maximums and minimums; maximum power transfer occurs when R_load = R_source.

# Quiz
Q: What is d/dx (4x³ − 2x + 7)?
* 12x² − 2
- 12x² − 2x
- 4x² − 2
- 12x³ − 2 + 7
> Power rule: 4 × 3x² = 12x²; −2x becomes −2; the constant 7 becomes 0.

Q: Using the chain rule, what is d/dx (e^(5x))?
- e^(5x)
* 5e^(5x)
- 5x·e^(5x−1)
- e^5
> The outer function eᵘ differentiates to eᵘ, times the derivative of the inner 5x, which is 5.

Q: A 10 µF capacitor's voltage rises at 2000 V/s. What current flows into it?
- 2 mA
* 20 mA
- 200 mA
- 0.2 mA
> i = C × dv/dt = 10 × 10⁻⁶ × 2000 = 0.02 A = 20 mA.

Q: What is true of the derivative at a smooth maximum point of a curve?
- It is at its largest value
* It equals zero
- It is undefined
- It is always negative
> At a peak the tangent is horizontal, so the gradient (the derivative) is zero.

Q: A 12 V source has 4 Ω internal resistance. What load resistance receives maximum power?
- 1 Ω
- 3 Ω
* 4 Ω
- 12 Ω
> Maximum power transfer occurs when the load resistance equals the source's internal resistance.
