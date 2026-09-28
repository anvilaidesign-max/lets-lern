---
topic: math
position: 1
title: Algebra, functions and logarithms
summary: Solving equations, what a function really is, quadratics and the quadratic formula, and why exponentials and logarithms appear everywhere.
difficulty: 1
sources:
- Wikipedia: Function (mathematics) | https://en.wikipedia.org/wiki/Function_(mathematics)
- Wikipedia: Quadratic formula | https://en.wikipedia.org/wiki/Quadratic_formula
- Wikipedia: Logarithm | https://en.wikipedia.org/wiki/Logarithm
---
## Equations as balances

An equation says two expressions are equal. Solving it means finding the values that make it true. The one rule: whatever you do to one side, do to the other.

> 5x − 7 = 18  →  5x = 25  →  x = 5

Always check by substituting back: 5 × 5 − 7 = 18. ✓

With two unknowns you need two equations. For x + y = 10 and x − y = 4, adding them gives 2x = 14, so x = 7 and y = 3. This is elimination; later you will see that matrices do the same job for large systems.

## Functions

A **function** is a rule that gives exactly one output for each input: f(x) = 2x + 3 turns 4 into 11. The set of allowed inputs is the **domain**; the set of outputs is the **range**. Functions are how we model the world: the current through a resistor as a function of voltage, the charge on a capacitor as a function of time.

A **linear** function f(x) = mx + c draws a straight line: m is the **gradient** (rise over run) and c is where it crosses the y-axis. A line through (1, 5) and (3, 11) has gradient (11 − 5) ÷ (3 − 1) = 3, so y = 3x + 2.

## Quadratics

A **quadratic** has the form ax² + bx + c. Its graph is a parabola: a U shape if a > 0, upside down if a < 0. Quadratics describe projectile motion, areas and the power dissipated in a resistor (P = I²R).

To solve ax² + bx + c = 0, try factorising first:

> x² − 5x + 6 = 0  →  (x − 2)(x − 3) = 0  →  x = 2 or x = 3

When factorising is hard, use the **quadratic formula**:

> x = (−b ± √(b² − 4ac)) ÷ 2a

The **discriminant** b² − 4ac tells you what to expect: positive means two real roots, zero means one repeated root, negative means no real roots (the roots are complex numbers, which appear in a later chapter and turn out to describe oscillating circuits).

![y = x² − 5x + 6 crosses the x-axis at its roots, x = 2 and x = 3; the vertex sits halfway between.](quadratic_roots)

## Exponentials

In an **exponential** function the variable is in the power: f(x) = aˣ. Exponentials describe anything that grows or decays by a fixed percentage per step: compound interest, population growth, radioactive decay and the charging of a capacitor.

The special base **e ≈ 2.71828** appears naturally in continuous growth. A capacitor charging through a resistor follows:

> V(t) = V_s × (1 − e^(−t/RC))

After one time constant (t = RC) it reaches about 63 percent of the supply; after five time constants it is essentially fully charged.

## Logarithms

A **logarithm** answers "what power?": log₁₀(1000) = 3 because 10³ = 1000. The natural log ln uses base e. Logarithms turn multiplication into addition, which is why they were used for calculation for centuries:

- log(ab) = log a + log b
- log(a ÷ b) = log a − log b
- log(aⁿ) = n × log a

Logarithms let you solve for an unknown in a power. How long until money doubles at 8 percent a year? Solve 1.08ⁿ = 2: n = ln 2 ÷ ln 1.08 ≈ 9 years (compare the rule of 72: 72 ÷ 8 = 9).

## Decibels

Engineers compress huge ranges with logarithmic scales. The **decibel** compares two powers:

> dB = 10 × log₁₀(P₂ ÷ P₁)      (for voltages: 20 × log₁₀(V₂ ÷ V₁))

Doubling power is about +3 dB; a tenfold voltage gain is +20 dB. Filter responses, amplifier gains and sound levels are all quoted in dB.

# Key points
- Solve equations by doing the same operation to both sides, then check by substitution.
- A function gives exactly one output per input; linear functions have a constant gradient.
- Quadratic formula: x = (−b ± √(b² − 4ac))/2a; the discriminant tells you how many real roots.
- Exponentials model constant-percentage growth and decay; e ≈ 2.718.
- Logarithms turn products into sums: log(ab) = log a + log b.
- Decibels: 10 log₁₀ of a power ratio, 20 log₁₀ of a voltage ratio.

# Quiz
Q: What are the solutions of x² − 7x + 12 = 0?
- x = −3 and x = −4
* x = 3 and x = 4
- x = 2 and x = 6
- x = 1 and x = 12
> It factorises to (x − 3)(x − 4) = 0, so x = 3 or x = 4.

Q: The discriminant of a quadratic is negative. What does that mean?
- It has two real roots
- It has one repeated real root
* It has no real roots
- The graph is a straight line
> A negative b² − 4ac means the square root is of a negative number, so there are no real solutions.

Q: What is log₁₀(0.01)?
- 2
- −0.01
* −2
- 0.2
> 0.01 = 10⁻², so log₁₀(0.01) = −2.

Q: What fraction of the supply voltage does a charging capacitor reach after one time constant?
- 37%
- 50%
* About 63%
- 100%
> V = V_s(1 − e⁻¹) ≈ V_s × 0.632.

Q: An amplifier boosts a signal from 10 mV to 1 V. What is its voltage gain in dB?
- 20 dB
* 40 dB
- 100 dB
- 10 dB
> The ratio is 100, and 20 × log₁₀(100) = 20 × 2 = 40 dB.
