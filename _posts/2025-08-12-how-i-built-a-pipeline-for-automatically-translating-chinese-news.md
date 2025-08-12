---
title: How I built a pipeline for automatically translating Chinese news
description: My goal was to automatically translate a Chinese news program called "Xinwen Lianbo", which has been broadcast on China Central Television since 1978. It's the most popular news program in China.
layout: post
lang: en
date: 2025-08-12
permalink: /en/blog/how-i-built-a-pipeline-for-automatically-translating-chinese-news/
---

Have you ever dreamed of an accurate, grammatically correct, practically independent and cheap tool for transcribing and automatically translating Chinese to English? I think I managed to create something like that recently and it works pretty well. In this article I'll tell the story of the problems I struggled with while creating the `cctv-xinwen-lianbo-en` tool, which I published yesterday on GitHub.

## Project Goal

My goal was to automatically translate a Chinese news program called "Xinwen Lianbo", which has been broadcast on China Central Television since 1978. It's the most popular news program in China, but I think mainly among older audiences – though I don't have confirmation of that. The program currently consists of important topics covering the latest economic, business, cultural, political and international data.

The idea of translating this program had been in my head for three years already. Until now I mainly read Chinese news, which is easier to translate. Unfortunately CCTV doesn't provide English subtitles for their news program, so there was an opportunity for automation. I created this tool mainly for myself, but I'm making it public because it's a valuable project that could be used by people learning Chinese or researchers – who could add sentiment analysis or keyword analysis to the project.

## What challenges did I encounter?

### First attempt – Whisper + Gemini

Initially I used OpenAI's Whisper model for transcription with MPS (Metal Performance Shader) support, which turned out to be insufficiently accurate. Inference also took too long. Additionally, timestamp marking didn't work effectively, even though I used the best `large-v3` model without distillation and quantization, which could lower quality.

For translations I used Gemini 2.5 Flash, which was effective, but often – even with an effective system prompt – its instruction-following was disrupted by the transcription text itself. This was a strange and definitely anomalous phenomenon. Additionally Gemini 2.5 Flash is a closed model, so it wasn't the best solution for an open-source project. I used Google's dedicated Gen AI library for Python, which limited flexibility. A potential developer or user of the tool would want to use a cheaper model more optimized for Chinese, but would have to rewrite the SDK to be compatible with the OpenAI API.

### Final solution – FunASR + Deepseek

Eventually I decided on a more thoughtful solution consisting of FunASR (Paraformer-zh), which Claude recommended to me after some research. It has good Python integration and is natively adapted for Chinese. It seems to work better than Whisper, additionally it effectively detects timestamps and – from what I know – has a different way of measuring them (at sentence level), which is much more accurate. It also supports punctuation marks, so it's practically an ideal solution.

As a translation model I chose Deepseek V3, which is cheap and quite accurate, especially when it comes to instruction-following – which was a problem with Gemini 2.5 Flash. It's a model created in China using a partially Chinese training dataset, so there's more chance of success. I used OpenRouter as the API.

### Context problem

After the changes, translation improved significantly, but there were still grammatical errors and those related to the structure of translated sentences. This was because the only context I was providing were individual SRT segments for translation. Because of this, sentences were often understandable, but very stripped of proper language.

I solved this with a modified workflow handling a context window with a default size of 3 segments – meaning 3 segments before and after the currently processed segment.

**Example:**

Segments: `[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]`

For segment 5 with `context_window=3`:

- Previous: `[2, 3, 4]` (3 segments before)
- Current: `[5]` (current segment to translate)
- Next: `[6, 7, 8]` (3 segments after)

This solution is effective and ensures terminology consistency and thematic continuity, which is extremely important in Chinese:

- Without context: "它" → "It"
- With context: "它" → "The technology" (when the previous segment talked about technology)

Unfortunately this has its downside – the beginning and end of the video are significantly limited contextually. Such a context window also handles short videos worse, but the project was specifically adapted for Chinese news "Xinwen Lianbo".

## Subtitle heuristics

### Quality heuristic

Another challenge was heuristics – I implemented several of them. The first was a quality heuristic that checked for repeating text (an error that arose during transcription still with the Whisper model). Using FunASR I no longer encountered this problem. It works by the SRT segment generated by transcription often having a repeating pattern, e.g. "你好你好你好你好你好". The heuristic detected such a pattern and marked the segment as erroneous, so as not to generate duplicating translation (typical for ASR errors in Chinese).

### Formatting parameters

Another important heuristic was subtitle formatting parameters. They're quite extensive and serve to make subtitles optimized and pleasant to read. These parameters were created through trial and error, but also thanks to suggestions from Claude, who most likely already had an embedded example with this type of heuristics:

```json
DEFAULT_MAX_LINE = 42        # Max characters per line
DEFAULT_MAX_LINES = 2        # Max 2 lines per subtitle
DEFAULT_MIN_DUR = 0.6        # Min duration (600ms)
DEFAULT_MAX_DUR = 7.0        # Max duration (7s)
DEFAULT_MAX_CPS = 16         # Max characters per second
```

These heuristics are connected to segment merging. If a segment is shorter than 0.6s, we try to merge it if:

```json
gap <= 0.25            # Gap ≤ 250ms
tentative_dur <= 7.0   # After merging ≤ 7s
tentative_cps <= 16    # Doesn't exceed 16 chars/s
```

### Automatic text splitting

Further heuristics serve among other things for automatic text splitting `_split_long_text_two_lines`. For languages with spaces (e.g. English or Polish) we look for the space closest to the middle and split the segment into two parts:

**"The digital rural construction promotes agricultural modernization"**
→ Line 1: "The digital rural construction"
→ Line 2: "promotes agricultural modernization"

### Timestamp shifting

Additionally I implement timestamp shifting, which serves to avoid subtitles starting too early in the SRT – still during the "Xinwen Lianbo" program intro, which lasts about 18 seconds.

---

## Links

If you want to test my project, check out the repository on GitHub: [cctv-xinwen-lianbo-en](https://github.com/piotrmaciejbednarski/cctv-xinwen-lianbo-en).
