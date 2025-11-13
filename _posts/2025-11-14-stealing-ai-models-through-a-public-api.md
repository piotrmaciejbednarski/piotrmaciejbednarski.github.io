---
title: Stealing AI models through a public API
description: How public AI APIs can be exploited to extract valuable models - from Facebook's image descriptions to commercial LLM endpoints. A look at invisible attacks that cost millions.
layout: post
lang: en
lang_alternate: /pl/blog/kradziez-modeli-ai-przez-publiczne-api/
date: 2025-11-14
permalink: /en/blog/stealing-ai-models-through-a-public-api/
tags:
  - AI Security
  - Machine Learning
  - API Exploitation
---

Every day, millions of people upload photos to Facebook, and alternative descriptions are automatically generated for them: "two men in a restaurant" or "woman with dog in a park." This feature is called Automatic Alt Text (created in 2017) and was designed for blind users. But it turns out it can be exploited in a completely different way.

Imagine an e-commerce store owner who needs descriptions for a hundred thousand product photos. They could pay hundreds of dollars to an external service, hire people, or... exploit Facebook. All it takes is a script that uploads photos as unpublished posts, extracts the generated descriptions, and then deletes the posts without a trace.

Facebook pays for each invocation of its computer vision model. The model cost millions of dollars in research and development, and now it works for free for someone else's business. Moreover, the store owner technically isn't breaking any rules - they're uploading photos to their platform, Facebook automatically generates descriptions, so they can be retrieved.

## When your own model starts working for the competition

The story doesn't end with tech giants. Let's say you spent three months building a message classifier. The model analyzes whether a user is trying to move a conversation off your platform - "write to me on WhatsApp" should be blocked. After many tests and improvements, your model achieves 95% accuracy.

You expose a simple endpoint: you send text, you get a true or false response. Seems harmless. But if someone writes a script that sends tens of thousands of different messages and records the responses, they can recreate your model's entire logic. They don't need access to the code or neuron weights - just knowledge of how the model responds to different texts.

After a few days of bombarding your endpoint, the attacker has a database of 50 thousand text-response pairs. That's enough to train their own model that will work practically identically. The cost? A few dozen dollars for cloud GPU. Your cost? Thousands of dollars in computations plus months of work on the algorithm.

The worst part is that in the server logs, you only see regular HTTP requests. Nothing indicates that someone is systematically copying your work. It's like theft in an art gallery where the thief doesn't take originals - just takes very detailed photos and then prints copies.

## Free language models for everyone

LM Arena is a platform where you can compare different large language models. You enter a question, choose a model, and get an answer. Sounds innocent, but underneath there's a public endpoint that can be used automatically.

Instead of paying Anthropic dozens of dollars per million Claude tokens, you can send requests through LM Arena for free. All you need is an appropriate script and a proxy to bypass basic limits. Some people build entire commercial applications this way, saving thousands of dollars monthly on API costs.

LM Arena is funded by research grants and donations to make technology accessible to a wider audience. I suspect that a significant portion of the traffic isn't researchers or students, but opportunists using the platform as free infrastructure for their own purposes.

## Anatomy of an invisible attack

Why are these attacks so effective? First, they look like normal traffic. If someone sends a hundred requests per hour for several days, it could just be an active user. Only pattern analysis reveals that the texts have improbably high randomness or that requests arrive at regular intervals characteristic of scripts.

Second, the cost of the attack is negligible compared to the value of stolen knowledge. Training a good classification model takes months of team work, thousands of dollars for GPU, and experiments with different architectures. Copying it through an API takes a few hours of script writing and the cost of a few dozen dollars for calls.

Third, the legal situation is murky. Is using a public API according to documentation, but for the purpose of recreating a model, theft of intellectual property? Does "mass endpoint querying" violate Terms of Service if there are no specified limits? Lawyers can argue for years, and meanwhile the model is already working at the competition.

## When features become holes

Facebook didn't plan for Automatic Alt Text to become a free API for product descriptions. LM Arena didn't expect to power commercial chatbots. Your message classifier was supposed to protect the platform, not teach the competition.

The problem is that every publicly available AI feature can be exploited contrary to its intended purpose. The simpler the interface and the fewer barriers, the easier it is to automate. What was a competitive advantage in the form of quick integration becomes a vulnerability enabling theft.

It's worth remembering this ambiguity when designing your own solutions. A publicly exposed model isn't just functionality for users, but potentially also free R&D for someone who is clever enough and has the right tools.

This is a new category of threats in the AI era - not exploits or break-ins, but systematic exploitation of what has been made legally available, but not in accordance with the creators' intentions. Sometimes the best protection is simply awareness that the problem exists.
