---
topic: math
position: 3
title: Calculus II: integrals and accumulation
summary: Integration as adding up tiny pieces, the fundamental theorem of calculus, key rules, and uses from areas to energy and RMS values.
difficulty: 2
sources:
- Wikipedia: Integral | https://en.wikipedia.org/wiki/Integral
- Wikipedia: Fundamental theorem of calculus | https://en.wikipedia.org/wiki/Fundamental_theorem_of_calculus
- Wikipedia: Root mean square | https://en.wikipedia.org/wiki/Root_mean_square
---
## Adding up tiny pieces

Suppose a car's speed changes continuously and you want the total distance. Over a very short interval dt, the distance is roughly v × dt. Add up all those thin strips and let them shrink to zero width: that sum is the **definite integral**:

> distance = ∫ from t₁ to t₂ of v(t) dt

Geometrically, a definite integral is the **area under a curve** between two limits (with areas below the axis counting as negative).

## The fundamental theorem of calculus

Integration and differentiation are inverse operations. This is the **fundamental theorem of calculus**, and it is what makes integrals practical to calculate. If F is a function whose derivative is f (an **antiderivative**), then:

> ∫ from a to b of f(x) dx = F(b) − F(a)

So to integrate, you run the derivative rules backwards.

## The basic rules

- **Power rule:** ∫ xⁿ dx = xⁿ⁺¹ ÷ (n + 1) + C, for n ≠ −1.
- **The special case:** ∫ (1/x) dx = ln|x| + C.
- **Exponentials:** ∫ eˣ dx = eˣ + C; ∫ e^(ax) dx = e^(ax) ÷ a + C.
- **Trig:** ∫ sin x dx = −cos x + C; ∫ cos x dx = sin x + C.

The **+ C** matters for indefinite integrals: any constant differentiates to zero, so an antiderivative is only known up to a constant. It cancels out in definite integrals.

Example: ∫ from 0 to 3 of x² dx = [x³/3] from 0 to 3 = 27/3 − 0 = 9.

![Thin strips under the curve add up to the area; make them thinner and the sum becomes the integral.](integral_area)

## Two useful techniques

- **Substitution** is the chain rule in reverse. For ∫ 2x·cos(x²) dx, let u = x², so du = 2x dx, and the integral becomes ∫ cos u du = sin(x²) + C.
- **Integration by parts** is the product rule in reverse: ∫ u dv = uv − ∫ v du. It handles products such as x·eˣ.

## Integrals in engineering

**Charge and current:** current is the rate of flow of charge, so charge is the integral of current: Q = ∫ i dt. A constant 2 A for 5 s moves 10 coulombs.

**Energy and power:** energy is the integral of power over time: E = ∫ P dt. This is how an electricity meter works: it integrates power continuously into kilowatt-hours.

**Capacitor voltage:** from i = C dv/dt, v = (1/C) ∫ i dt. Charging a capacitor with a constant current makes its voltage rise in a straight line: the principle behind ramp generators and integrating ADCs.

**The integral controller:** the I in PID integrates the error over time, so even a small persistent error builds up a correction until it is eliminated.

## Averages and RMS values

The **average** value of a function over an interval is the integral divided by the interval length. A full sine wave averages to zero, because the positive and negative halves cancel. That is why AC is described by its **RMS** value: square the signal (making everything positive), average it, then take the square root:

> V_rms = √[ (1/T) ∫ from 0 to T of v(t)² dt ]

For v = V_p sin(ωt), the average of sin² over a cycle is 1/2, which gives V_rms = V_p ÷ √2. For a square wave that switches between +V and −V, V_rms = V exactly.

## When there is no formula

Many integrals have no neat antiderivative, and real measured data never does. Then we use **numerical integration**: the trapezoidal rule and Simpson's rule approximate the area with straight lines or parabolas. Every digital energy meter, flow totaliser and physics simulation does this millions of times a second.

# Key points
- A definite integral adds up infinitely many thin strips: the area under a curve.
- Fundamental theorem: ∫ from a to b of f dx = F(b) − F(a), where F′ = f.
- ∫ xⁿ dx = xⁿ⁺¹/(n+1) + C (n ≠ −1); ∫ 1/x dx = ln|x| + C.
- Charge is the integral of current; energy is the integral of power.
- RMS = square root of the mean of the square; for a sine wave V_rms = V_p/√2.

# Quiz
Q: What is ∫ from 0 to 2 of 3x² dx?
- 6
* 8
- 12
- 4
> The antiderivative is x³. Evaluate: 2³ − 0³ = 8.

Q: What is the indefinite integral of 1/x?
- x⁰
- −1/x² + C
* ln|x| + C
- The power rule gives x⁰/0
> The power rule fails for n = −1; the answer is the natural logarithm.

Q: A constant current of 3 A flows for 20 seconds. How much charge passes?
- 6.7 C
* 60 C
- 23 C
- 0.15 C
> Q = ∫ i dt = 3 × 20 = 60 coulombs.

Q: Why is the average value of a full sine wave not useful for describing AC power?
- It is always infinite
* The positive and negative halves cancel, so it averages to zero
- It equals the peak value
- It cannot be calculated
> Over a full cycle a sine wave averages to zero, so we use RMS, which squares the signal first.

Q: What is the RMS value of a square wave switching between +10 V and −10 V?
- 7.07 V
* 10 V
- 0 V
- 14.1 V
> Squaring gives 100 at every instant, the mean is 100, and √100 = 10 V.
