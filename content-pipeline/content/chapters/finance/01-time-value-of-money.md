---
topic: finance
position: 1
title: The time value of money
summary: Why money today is worth more than money later, compound interest and the rule of 72, inflation and real returns, present value and NPV for projects, and how loans really cost you.
difficulty: 2
sources:
- Wikipedia: Time value of money | https://en.wikipedia.org/wiki/Time_value_of_money
- Wikipedia: Compound interest | https://en.wikipedia.org/wiki/Compound_interest
- Wikipedia: Net present value | https://en.wikipedia.org/wiki/Net_present_value
- Wikipedia: Real interest rate | https://en.wikipedia.org/wiki/Real_interest_rate
---
## A dollar today beats a dollar tomorrow

Would you rather have 100 dollars today or 100 dollars in a year? Almost everyone chooses today, for good reasons:

- You could **invest** it and have more than 100 in a year.
- **Inflation** may reduce what 100 can buy next year.
- The future is **uncertain**: the promise might not be kept.

This idea, the **time value of money**, sits underneath every loan, savings account, investment, pension and business decision.

## Simple and compound interest

With **simple interest**, you earn interest only on the original amount. With **compound interest**, interest is added to the balance, so next year you earn interest on the interest too.

> Future value: FV = PV × (1 + r)ⁿ, where PV is the amount today, r the interest rate per period and n the number of periods.

At 10% a year, 1,000 grows to:

- **Simple:** 1,000 + 30 × 100 = 4,000 after 30 years.
- **Compound:** 1,000 × 1.1³⁰ ≈ 17,449 after 30 years.

The difference is dramatic, and it comes mostly from the later years. That is why starting to save early matters more than saving large amounts later. Albert Einstein probably never called compound interest the eighth wonder of the world, but the maths deserves the praise.

![Both start at 1,000, but after 30 years compounding gives more than four times as much as simple interest.](compound_growth)

## The rule of 72

A quick mental shortcut: money growing at r% a year **doubles in about 72 ÷ r years**.

- At 6%, it doubles in about 12 years.
- At 12%, in about 6 years.
- It works for anything growing steadily: at 3% inflation, prices double in about 24 years.

## Compounding frequency and APR

Interest can compound yearly, monthly or even daily. A loan quoting 24% a year charged as 2% a month actually costs more than 24%:

> Effective annual rate = (1 + 0.02)¹² − 1 ≈ 26.8%

Lenders often advertise the lower **nominal rate** (APR). Always compare the **effective annual rate**, including fees. Short-term mobile loans and payday loans can have effective annual rates in the hundreds of percent even when the monthly fee looks small.

## Inflation and real returns

**Inflation** is the general rise in prices. If your savings earn 8% while prices rise 10%, your money buys less at the end of the year than at the start. What matters is the **real return**:

> Real return ≈ nominal return − inflation (more precisely, (1 + nominal) ÷ (1 + inflation) − 1)

Zimbabweans know this better than most. In 2008, hyperinflation wiped out savings held in Zimbabwe dollars within months. Since then, the country has used US dollars alongside local currencies, from bond notes and the RTGS/Zimbabwe dollar to **ZiG** (Zimbabwe Gold), launched in April 2024. The lesson: keep savings in a form whose value you trust, and judge any interest rate against the inflation rate of that currency.

## Present value: bringing the future back

Compounding runs forward; **discounting** runs backwards. What is 1,000 received in 3 years worth today if you could earn 10%?

> PV = FV ÷ (1 + r)ⁿ = 1,000 ÷ 1.1³ ≈ 751

The rate used, the **discount rate**, reflects what you could earn elsewhere and how risky the cash flow is. Riskier promises are discounted at higher rates, so they are worth less today.

## NPV: should we build it?

Engineers and businesses use **net present value (NPV)** to decide whether a project is worth doing. Add up the present value of all future cash flows, then subtract the upfront cost:

> Example: a solar installation costs 10,000 and saves 3,000 a year for 5 years. At a 10% discount rate, the present value of the savings is about 11,372, so NPV ≈ +1,372. A positive NPV means the project creates value.

At a 20% discount rate the same savings are worth only about 8,972, giving a negative NPV. The discount rate matters enormously. The **internal rate of return (IRR)** is the discount rate at which NPV is exactly zero; here it is about 15%. Projects whose IRR beats the cost of capital are worth doing.

## Loans and amortisation

Most loans are repaid in equal instalments. Early payments are mostly **interest**; later ones mostly repay the **principal**. On a 20-year mortgage, the first years barely dent the balance. Paying a little extra early saves a lot of interest, because it removes principal that would otherwise have compounded for years.

Good debt finances something that earns more than it costs, such as equipment that raises income or education that raises earnings. Bad debt finances consumption at high rates. Before borrowing, compare the effective rate with the return you expect.

# Key points
- Money today is worth more than the same money later because of returns, inflation and risk.
- Compound interest: FV = PV × (1 + r)ⁿ; over long periods it hugely outgrows simple interest.
- Rule of 72: doubling time ≈ 72 ÷ interest rate.
- Compare loans using the effective annual rate, not the advertised nominal rate.
- Real return ≈ nominal return − inflation.
- Present value discounts future cash; a positive NPV means a project creates value.

# Quiz
Q: Roughly how long does money take to double at 8% a year?
- 4 years
* 9 years
- 12 years
- 18 years
> By the rule of 72: 72 ÷ 8 = 9 years.

Q: Your savings earn 6% a year while inflation is 9%. What is happening to your purchasing power?
- It rises by 6%
- It rises by 15%
* It falls by about 3% a year
- It stays the same
> Real return ≈ 6% − 9% = −3%: your money buys less each year.

Q: A loan charges 3% per month, compounded. What is the effective annual rate?
- 36%
* About 42.6%
- 3%
- About 30%
> (1.03)¹² − 1 ≈ 0.426, so about 42.6%, well above the simple 12 × 3% = 36%.

Q: What is the present value of 1,210 received in 2 years at a 10% discount rate?
- 1,100
* 1,000
- 1,210
- 968
> PV = 1,210 ÷ 1.1² = 1,210 ÷ 1.21 = 1,000.

Q: A project has a positive NPV at the company's cost of capital. What does that mean?
* It is expected to create value and is worth doing
- It will lose money
- It has no risk
- It pays back in one year
> Positive NPV means discounted future cash flows exceed the upfront cost.
