---
topic: math
position: 6
title: Complex numbers, Fourier and Laplace
summary: The imaginary unit, polar form and Euler's formula, phasors for AC circuits, and how Fourier and Laplace transforms turn hard problems into easy ones.
difficulty: 3
sources:
- Wikipedia: Complex number | https://en.wikipedia.org/wiki/Complex_number
- Wikipedia: Euler's formula | https://en.wikipedia.org/wiki/Euler%27s_formula
- Wikipedia: Fourier series | https://en.wikipedia.org/wiki/Fourier_series
- Wikipedia: Laplace transform | https://en.wikipedia.org/wiki/Laplace_transform
---
## The imaginary unit

No real number squares to −1, so mathematicians defined one: i² = −1. Electrical engineers write it as **j**, because i is already used for current. A **complex number** z = a + jb has a real part a and an imaginary part b, and can be drawn as a point on a plane (the Argand diagram).

Arithmetic follows normal algebra, replacing j² with −1:

> (3 + j2)(1 − j4) = 3 − j12 + j2 − j²8 = 3 − j10 + 8 = 11 − j10

## Polar form

A complex number can also be described by its length (**magnitude**) r and its angle θ from the real axis:

> r = √(a² + b²)      θ = arctan(b ÷ a)

So 3 + j4 has magnitude 5 and angle about 53.1°, written 5∠53.1°. Polar form makes multiplication easy: **multiply the magnitudes and add the angles**. Division divides magnitudes and subtracts angles.

![The same number in two forms: 3 + j4 in rectangular form is 5∠53.1° in polar form.](complex_plane)

## Euler's formula

The link between the two forms is **Euler's formula**:

> e^(jθ) = cos θ + j sin θ

so z = r·e^(jθ). With θ = π it gives e^(jπ) + 1 = 0, often called the most beautiful equation in mathematics because it connects e, i, π, 1 and 0. For engineers its value is practical: rotation becomes multiplication, and a sine wave becomes a rotating arrow.

## Phasors: AC circuits made easy

A sinusoid V_p cos(ωt + φ) can be represented by a fixed complex number V∠φ, a **phasor**, as long as every signal has the same frequency. Then capacitors and inductors become simple complex impedances:

> Z_R = R      Z_L = jωL      Z_C = 1 ÷ (jωC) = −j ÷ (ωC)

Ohm's law and Kirchhoff's laws work unchanged with complex numbers. Calculus problems become algebra.

**Example:** R = 30 Ω in series with an inductor of X_L = 40 Ω: Z = 30 + j40 = 50∠53.1° Ω. With 230∠0° V applied, I = 230 ÷ 50∠53.1° = 4.6∠−53.1° A. The negative angle shows the current lags the voltage, exactly as the AC chapter described.

## Fourier: every signal is a sum of sines

Joseph Fourier showed in the early 1800s that any periodic signal can be built from sine and cosine waves at a fundamental frequency and its whole-number multiples (**harmonics**). A square wave, for example, contains the fundamental plus odd harmonics at 1/3, 1/5, 1/7 of its strength, and so on.

The **Fourier transform** extends this to any signal, describing it as a spectrum of frequencies. Engineers use it constantly:

- to analyse harmonics that non-linear loads (rectifiers, VFDs) inject into the power grid,
- to design filters and understand bandwidth,
- in audio compression (MP3), images (JPEG) and Wi-Fi and 4G/5G radio (OFDM).

The **FFT** (fast Fourier transform) is the algorithm that makes this quick enough to run in real time.

## Laplace: solving circuits and control systems

The **Laplace transform** converts a function of time f(t) into a function of a complex variable s. Its superpower is that it turns differentiation into multiplication by s:

> L{df/dt} = s·F(s) − f(0)

Differential equations describing circuits and machines become algebraic equations. You solve them in the s-domain, then transform back. A few standard pairs cover most practical cases: L{1} = 1/s, L{e^(−at)} = 1/(s + a), L{sin ωt} = ω/(s² + ω²).

In control engineering, systems are described by **transfer functions** such as G(s) = 1 ÷ (τs + 1) for a first-order process like a heating tank or an RC filter. The roots of the denominator, the **poles**, decide behaviour: poles in the left half of the s-plane mean a stable system, and poles in the right half mean it runs away.

# Key points
- j² = −1; complex numbers have real and imaginary parts.
- Polar form r∠θ: multiply magnitudes and add angles.
- Euler's formula: e^(jθ) = cos θ + j sin θ.
- Phasors turn AC calculus into algebra: Z_L = jωL, Z_C = 1/(jωC).
- Fourier: any periodic signal is a sum of harmonics; the FFT computes spectra fast.
- Laplace turns differential equations into algebra; left-half-plane poles mean stability.

# Quiz
Q: What is (2 + j3) + (4 − j5)?
* 6 − j2
- 6 + j8
- −2 + j8
- 8 − j15
> Add real parts (2 + 4 = 6) and imaginary parts (3 − 5 = −2).

Q: What is the magnitude of 5 + j12?
- 17
- 7
* 13
- 60
> √(5² + 12²) = √(25 + 144) = √169 = 13.

Q: In polar form, what is (2∠30°) × (3∠40°)?
- 5∠70°
* 6∠70°
- 6∠10°
- 6∠1200°
> Multiply the magnitudes (2 × 3 = 6) and add the angles (30° + 40° = 70°).

Q: What is the complex impedance of an inductor?
- R
* jωL
- 1/(jωC)
- ωL with no j
> An inductor's impedance is jωL: its size grows with frequency and it adds +90° of phase.

Q: A system's transfer function has a pole in the right half of the s-plane. What does this mean?
- The system is stable
* The system is unstable
- The system has no output
- The system is a pure resistor
> Right-half-plane poles correspond to responses that grow over time, so the system is unstable.
