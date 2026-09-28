---
topic: math
position: 5
title: Probability and statistics
summary: The rules of probability, Bayes' theorem, expected value, spread, the normal distribution and why samples can mislead.
difficulty: 2
sources:
- Wikipedia: Probability | https://en.wikipedia.org/wiki/Probability
- Wikipedia: Bayes' theorem | https://en.wikipedia.org/wiki/Bayes%27_theorem
- Wikipedia: Normal distribution | https://en.wikipedia.org/wiki/Normal_distribution
- Wikipedia: Central limit theorem | https://en.wikipedia.org/wiki/Central_limit_theorem
---
## The basic rules

A **probability** is a number from 0 (impossible) to 1 (certain). For equally likely outcomes:

> P(event) = favourable outcomes ÷ total outcomes

Rolling a fair die, P(even) = 3/6 = 0.5.

- **Complement:** P(not A) = 1 − P(A).
- **Or (mutually exclusive events):** P(A or B) = P(A) + P(B).
- **And (independent events):** P(A and B) = P(A) × P(B). Two heads in two fair coin tosses: 0.5 × 0.5 = 0.25.

"At least one" questions are easiest through the complement. The chance of at least one six in four rolls is 1 − (5/6)⁴ ≈ 0.52.

## Conditional probability and Bayes' theorem

P(A | B) means the probability of A given that B happened. **Bayes' theorem** reverses a conditional probability:

> P(A | B) = P(B | A) × P(A) ÷ P(B)

**The classic example:** a disease affects 1 in 1000 people. A test catches 99 percent of real cases but also gives a false positive for 2 percent of healthy people. You test positive. How likely are you to have the disease?

In 100,000 people, 100 have the disease and 99 of them test positive. Of the 99,900 healthy people, 2 percent (1998) also test positive. So of 2097 positives, only 99 are real:

> P(disease | positive) = 99 ÷ 2097 ≈ 4.7 percent

When a condition is rare, most positives are false, even with a good test. This is why doctors confirm with a second test, and why ignoring the **base rate** is one of the most common reasoning errors.

## Expected value

The **expected value** is the long-run average outcome: multiply each outcome by its probability and add them up. A game that pays $10 with probability 0.1 and costs $2 to play has an expected value of 0.1 × 10 − 2 = −$1 per play. Lotteries and casinos are built on negative expected values for the player; insurance works because customers accept a small expected loss to avoid a large risk.

## Describing data

- **Mean:** the sum divided by the count. Sensitive to outliers.
- **Median:** the middle value when sorted. Robust to outliers, which is why incomes are usually reported as medians.
- **Standard deviation (σ):** the typical distance of values from the mean. Small σ means the data is tightly clustered.

## The normal distribution

Many measurements (heights, measurement errors, component tolerances) follow the bell-shaped **normal distribution**, fixed by its mean μ and standard deviation σ. The **68–95–99.7 rule** says about 68 percent of values fall within 1σ of the mean, 95 percent within 2σ and 99.7 percent within 3σ.

If resistors marked 100 Ω have σ = 1 Ω, about 95 percent will measure between 98 and 102 Ω. Manufacturing quality programmes such as Six Sigma aim to keep defects many standard deviations away from the average.

![About 68% of values fall within 1 standard deviation of the mean, 95% within 2 and 99.7% within 3.](normal_curve)

## Why the normal distribution is everywhere

The **central limit theorem** says that the average of many independent random effects tends towards a normal distribution, whatever the shape of each individual effect. Noise in a circuit is the sum of countless tiny random events, so it is close to normal. This theorem is also why opinion polls and quality checks can work from samples.

## Samples, correlation and traps

- **Sample size:** the uncertainty of an average shrinks with the square root of the sample size. Quadrupling the sample halves the error.
- **Bias:** a large sample is useless if it is not representative. An online poll of an app's users says little about a whole country.
- **Correlation is not causation:** ice cream sales and drownings rise together because both rise in hot weather, not because one causes the other.

# Key points
- P(not A) = 1 − P(A); independent events multiply: P(A and B) = P(A)·P(B).
- Bayes' theorem: P(A|B) = P(B|A)·P(A)/P(B); with rare conditions, most positive tests can be false.
- Expected value = Σ outcome × probability; it is the long-run average.
- The median resists outliers; the standard deviation measures spread.
- Normal distribution: 68% within 1σ, 95% within 2σ, 99.7% within 3σ.
- Correlation does not prove causation, and biased samples mislead however large they are.

# Quiz
Q: What is the probability of rolling two sixes with two fair dice?
- 1/6
- 1/12
* 1/36
- 2/6
> The rolls are independent: 1/6 × 1/6 = 1/36.

Q: What is the probability of getting at least one head in three fair coin tosses?
- 1/2
- 3/4
* 7/8
- 1/8
> The complement is three tails: (1/2)³ = 1/8, so at least one head is 1 − 1/8 = 7/8.

Q: A bet pays $50 with probability 0.02 and costs $2. What is its expected value?
- +$1
* −$1
- +$48
- −$2
> 0.02 × 50 − 2 = 1 − 2 = −$1 per bet.

Q: Measurements are normal with mean 50 and σ = 5. About what percentage fall between 40 and 60?
- 68%
* 95%
- 99.7%
- 50%
> 40 to 60 is the mean ± 2σ, which contains about 95% of values.

Q: Why is median income usually reported instead of mean income?
- It is always higher
* A few very high incomes pull the mean up but barely move the median
- It is easier to calculate
- The mean cannot be calculated for money
> The median is the middle value, so extreme values do not distort it.
