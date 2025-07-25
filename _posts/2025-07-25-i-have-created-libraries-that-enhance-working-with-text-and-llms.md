---
title: I have created libraries that enhance working with text and LLMs
description: I noticed that this field is very neglected – some libraries haven't been updated for a year or ten years, but still, many people use them. Therefore, I thought that something new that would find application in NLP for Node.js projects would hit a niche and fill a certain technological gap.
layout: post
lang: en
date: 2025-07-25
permalink: /en/blog/i-have-created-libraries-that-enhance-working-with-text-and-llms/
---

It's been a while since I last wrote on the blog, but I finally have something to write about. You'll have to get used to my approach – I wouldn't want to write here about unimportant or insignificant things. I also don't want to directly talk about what I do at work or in my profession, but rather publish things that, first of all, I can share, and secondly, I find interesting to share with the world.

Recently, I was working on one project idea that could be highly revolutionary, but I put it aside after creating a prototype and thorough documentation. I'll probably tell you more about it in the future, but I'll reveal that sharing it with the world would change what we commonly consider reverse engineering – in the context of digital integrated circuits. I can't reveal more at the moment, but stay tuned for an article on this topic! If I complete this project, a preprint will probably appear on arXiv, so you're probably thinking it's something innovative (and it will be!).

I recently published two libraries that I'm very proud of. The first one is [text-similarity-node](https://github.com/piotrmaciejbednarski/text-similarity-node) – a library written in C++17 for Node.js (it uses [NAPI](https://nodejs.org/api/n-api.html) to use C++ functions in JavaScript). This library provides many text comparison algorithms and, most importantly, has low memory usage and garbage collector utilization, and is quite efficient in the real world, although some JavaScript implementations outperform it.

My library intentionally has high abstraction in C++, which significantly reduces its performance, and the NAPI time overhead for each operation in JavaScript causes me to have significant technical limitations. Nevertheless, it is relatively efficient and scales very well in operations on large string lengths, which is a big plus for my library. I'm currently working on rewriting my library to WASM + Rust (using the [wasm-pack](https://github.com/drager/wasm-pack) tool) without the abstraction layer (I want to focus on low-level) and backward compatibility, as well as algorithmic compatibility with the reference library (more on that in a moment). Fortunately, I already have experience writing Rust code; for example, I wrote a [Rust library for handling UPS devices](https://github.com/piotrmaciejbednarski/megatec-ups-control), which I recommend checking out. If you've ever used UPS devices, you've probably encountered the UPSilon 2000 software – I ported the functionality of this program to a library that operates at a low level, and I recreated everything through reverse engineering. If successful, text-similarity-node will be a great alternative to most alternative libraries implemented in JavaScript. To inform my users who use the library, I created a postinstall script that informs them of planned actions.

I had a big problem – how to verify that my algorithmic implementations work correctly (according to theory)? So I used [TextDistance](https://github.com/life4/textdistance) in Python, which is a valued and proven library. It does roughly the same thing as my library, and its internal implementations of various algorithms (coming from different repositories or Wikipedia) allowed me to save work and additionally verify my algorithms by checking if the reference library returns roughly the same results.

I achieved 95% effectiveness except for the Cosine Similarity algorithm, because I solved the tokenization issue differently in my library. How surprised I was when it turned out that Cosine Similarity in TextDistance is actually the Ochiai coefficient! They should name this algorithm directly instead of generally naming the class `[Cosine(_BaseSimilarity)](https://github.com/life4/textdistance/blob/d6a68d61088a40eef5c88191ccf79323dbf34850/textdistance/algorithms/token_based.py#L182)`. This is one of the least standardized ways of measuring text similarity.

There were also issues with packaging this library, as I had never done it before. The Node.js library itself is not a problem, but when you combine it with C++ and NAPI, the whole thing starts to get complicated. I didn't want to share a library that everyone has to compile on their hardware – which requires time and installation of various tools and the compiler itself. Fortunately, some good person on this earth created the [prebuildify](https://github.com/prebuild/prebuildify) package, which allows delivering built artifacts (.node) via node-gyp (a tool for compiling native addons for Node.js) directly in the NPM package. After installation, the user uses the appropriate prebuilt binary built for the platform they are using, and the whole thing looks like installing a regular JavaScript package.

I provided x64/arm64 platforms for Windows, Linux, and macOS, which are built by GitHub Actions (on which I spent a lot of money before I managed to test everything – the most troublesome was testing compilation on Windows and frequent issues with stripping built into prebuildify). I also implemented [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) in my library, but I haven't fully verified yet if it works completely – some functions don't fully utilize SIMD, but I consider this a good start. I noticed somewhere on the internet that it's recommended to use SIMD for native addons, so I tried to do it, but I'll perform the verification (probably a benchmark with and without SIMD) only soon. Well, at least I'm honest…

Actually, the benchmark in my project (implemented thanks to [tinybench](https://github.com/tinylibs/tinybench), which seems more precise and lighter than benchmark.js) shows that my library performs quite well, although it often fails in terms of ops/s (operations per second), but the differences remain invisible in real applications. The plus is that regardless of input data scaling, I have predictable performance and stability, as well as better memory management, asynchronous API, and full Unicode and library configuration support – which other Node.js libraries don't have. For this reason, I can say that my library is definitely more elaborate and efficient in real projects.

I noticed that this field is very neglected – some libraries haven't been updated for a year or ten years, but still, many people use them. Therefore, I thought that something new that would find application in NLP for Node.js projects would hit a niche and fill a certain technological gap.

The second library I published is a really lightweight and simple implementation of the functionality named "Structured Outputs" in the OpenAI API. In short, it's about the fact that we often want the LLM to return a response in a structural form, e.g., JSON or a Pydantic model (in practice, it's the same because we perform serialization of the Pydantic model to JSON).

Let me introduce [structllm](https://github.com/piotrmaciejbednarski/structllm)! It's a very simple library for Python 3.x that uses [LiteLLM](https://github.com/BerriAI/litellm) as a universal client supporting many providers in a unified OpenAI API format. This means that from the same API and format, we can communicate with Anthropic, Gemini, Vertex, Cohere, Mistral models, or models from OpenRouter.

StructLLM allows implementing "Structured Outputs" from OpenAI and works on the following principle:

We provide a [Pydantic](https://docs.pydantic.dev/latest/) model in which we want to receive the output result from the LLM. Under the hood, we inject the serialized structure of this Pydantic model into the system prompt:

```
"You must respond with a valid JSON object that conforms exactly "
"to the following schema. "
"IMPORTANT: Do not use Markdown formatting, just return the JSON "
"object directly.\\n\\n"
f"JSON Schema:\\n{json.dumps(schema, indent=2)}"
```

Then we put this into the system prompt in the conversation with top_p and temperature set to 0.1 (for predictability and little creativity, because we are performing a structural task). We provide a request in the conversation, e.g.:

```python
messages = [
    {"role": "system", "content": "Extract the event information."},
    {
        "role": "user",
        "content": "Alice and Bob are going to a science fair on Friday.",
    },
]
```

The LLM will respond in the way we defined the Pydantic model, according to typing and structure, and the library automatically parses the LLM's response as JSON and converts it back to a Pydantic BaseModel.

Very simple, but it works, and I needed it in one project I'm working on at work, which is why the idea of creating this project appeared in the first place.

Additionally, in several projects, I noticed that developers often misconfigure their system prompt for structural LLM output and directly load the raw LLM response as JSON without any parsing. They simply assume that the LLM's response will be purely structural, so my library tries to unify everything and provide parsing, validation, and everything needed for a simple task related to structural output from LLM.

I haven't really advertised my new libraries, so recognition will probably come with time. By the way, I started committing to the [FluxLang](https://github.com/kvthweatt/FluxLang) repository – it's some compiler for a programming language based on LLVM, created by some hobbyist developer. I helped him a bit by organizing his project and adding a few features to his compiler. I'm also slowly developing its standard library. I saw this project on HackerNews (Y Combinator) in the form of an advertisement, so I decided to contribute my part.
