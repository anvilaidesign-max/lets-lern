---
topic: tech
position: 3
title: Artificial intelligence and machine learning
summary: How machines learn from data, what neural networks and large language models are, why GPUs matter, and the real limits and risks of AI.
difficulty: 2
sources:
- Wikipedia: Machine learning | https://en.wikipedia.org/wiki/Machine_learning
- Wikipedia: Neural network (machine learning) | https://en.wikipedia.org/wiki/Neural_network_(machine_learning)
- Wikipedia: Large language model | https://en.wikipedia.org/wiki/Large_language_model
- Wikipedia: Transformer (deep learning architecture) | https://en.wikipedia.org/wiki/Transformer_(deep_learning_architecture)
---
## Rules versus learning

Traditional software follows rules a programmer writes: "if the temperature is above 80, sound the alarm". **Machine learning (ML)** works differently: instead of writing the rules, you show the computer many examples and let it find the patterns itself. That makes ML powerful for problems where rules are hard to write down, such as recognising a face, understanding speech or spotting fraud.

**Artificial intelligence (AI)** is the broad goal of making machines perform tasks that normally need human intelligence. Machine learning is the approach behind nearly all of today's AI.

## Three ways machines learn

- **Supervised learning:** learn from labelled examples, such as thousands of X-ray images each marked "fracture" or "no fracture". The model learns to predict the label for new images.
- **Unsupervised learning:** find structure in unlabelled data, such as grouping customers with similar buying habits.
- **Reinforcement learning:** learn by trial and error with rewards, the way systems learned to play Go and chess at superhuman level.

## Neural networks

A **neural network** is loosely inspired by the brain. It is built from layers of simple units ("neurons"). Each unit multiplies its inputs by **weights**, adds them up and passes the result through a simple function. The first layer takes raw data (pixel values, for example); later layers combine the results into more abstract features (edges, then shapes, then faces).

**Training** means adjusting millions or billions of weights so the network's predictions match the examples. The network makes a prediction, measures its error, and an algorithm called **backpropagation** works out how each weight should change to reduce that error, a little at a time, over many passes through the data. Networks with many layers are called **deep learning**.

![Each connection has a weight; training nudges millions or billions of weights to reduce the error.](neural_network)

## Large language models

**Large language models (LLMs)**, such as the ones behind ChatGPT, Claude, Gemini and DeepSeek, are neural networks trained on enormous amounts of text to predict the next word (more precisely, the next **token**, a word or piece of a word). Doing that well across billions of examples forces the model to learn grammar, facts, reasoning patterns and style.

Most modern LLMs use the **transformer** architecture, introduced in the 2017 paper "Attention Is All You Need". Its key idea, **attention**, lets the model weigh how relevant every earlier word is when predicting the next one, so it can follow long contexts.

After this pre-training, models are usually fine-tuned with human feedback to follow instructions and be more helpful and safer. This app's AI tutor and essay scorer use an LLM in exactly this way.

## Why GPUs matter

Training and running neural networks is mostly huge amounts of matrix multiplication (see the linear algebra chapter in Mathematics). **GPUs**, originally designed for video game graphics, perform thousands of these calculations in parallel, which made modern AI practical. Training the largest models takes thousands of GPUs running for weeks and costs very large sums of money and electricity.

## Limits and risks

AI is useful but not magic. Know its weaknesses:

- **Hallucination:** LLMs can state false facts confidently, because they generate plausible text rather than look things up. Check important claims.
- **Bias:** models learn from human data, including its biases. A hiring model trained on past decisions can repeat past discrimination.
- **Data quality:** a model is only as good as its training data. Garbage in, garbage out.
- **Privacy:** information you type into online AI tools may be stored and processed by the provider.
- **Misuse:** deepfakes, automated scams and misinformation are real problems.

Used well, AI is a powerful assistant: it drafts, explains, translates, summarises and codes. The skill that matters is knowing when to trust it and how to check it.

# Key points
- Machine learning finds patterns from examples instead of following hand-written rules.
- Supervised learning uses labelled examples; unsupervised finds structure; reinforcement learns from rewards.
- Neural networks learn by adjusting weights to reduce error (backpropagation).
- LLMs predict the next token; most use the transformer architecture from 2017.
- GPUs make AI practical because they do massive parallel matrix maths.
- AI can hallucinate and carry bias, so check important outputs.

# Quiz
Q: What is the main difference between traditional programming and machine learning?
- Machine learning does not use computers
* In machine learning the computer learns patterns from examples instead of following hand-written rules
- Traditional programs are always faster
- Machine learning never makes mistakes
> ML models learn from data; traditional software follows rules a programmer writes.

Q: Which kind of learning uses examples that are already labelled with the correct answer?
* Supervised learning
- Unsupervised learning
- Reinforcement learning
- Rote learning
> Supervised learning trains on inputs paired with the correct labels.

Q: What does a large language model fundamentally predict?
- The weather
* The next token in a sequence of text
- The user's location
- Stock prices
> LLMs are trained to predict the next token; abilities like answering questions emerge from doing this well at huge scale.

Q: Why are GPUs so important for AI?
- They have more storage than CPUs
* They perform thousands of matrix calculations in parallel
- They connect to the internet faster
- They use no electricity
> Neural networks are mostly matrix multiplication, which GPUs do massively in parallel.

Q: What is an AI "hallucination"?
- A picture generated by AI
* A confident but false statement produced by the model
- A virus in the model
- A very fast answer
> Models generate plausible text, which can sometimes be wrong while sounding certain.
