---
title: front matter is not a heading
---

# Using _fastlane_ with `get_build_number`

Valid: [same file](#using-fastlane-with-get_build_number), [other file](sub/other.md), [other heading](sub/other.md#setext-title),
[duplicate](#details-1), [html heading](#from-html), [explicit id](#custom-anchor), [image](sub/image.png?raw=true),
[external](https://docs.fastlane.tools/missing/), [site path](/actions/gym/), [mail](mailto:someone@example.com), [defined][ref], [ref][].

Ignored: `[in code](missing.md)`

```
[in a fence](missing.md)
```

## Details

## Details

<h3 align="center">From HTML</h3>

<a id="custom-anchor"></a>

Broken: [missing file](missing.md), [missing heading](#nowhere), [missing other heading](sub/other.md#nowhere),
[undefined][nope], <a href="sub/missing.md">html link</a>, [bad definition][bad].

[ref]: sub/other.md
[bad]: sub/gone.md
