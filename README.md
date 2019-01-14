# SWFTY

![SWFTY](https://github.com/starburst997/SWFTY/raw/master/ref/swfty.gif)

### Try the [HTML5 Demo](https://starburst997.github.io/SWFTY/)

**WIP** *Not to be used in production yet, PRs, issues, etc. are very much welcome*

## Purpose
Create a cross-engine high-performance SWF rendering layer (no code, graphics / texts only) using Spritesheet (1 draw call per SWF).

Can facilitate migration from OpenFL to Heaps or to get a performance boost on OpenFL.

Currently works on Heaps and OpenFL but other engine are in the work (Kha, PixiJS and Unity).

## TODO
Create a README with online (HTML5) example

## Samples
Samples projects include 3 different version of OpenFL (8.4.0, 8.7.0 and 5.0.0) for benchmarks testing, you can also try different renderers: pure SWFTY (1 draw call), SWFTY display list (individual bitmaps) and OpenFL's SWF Lite.

It currently puzzles me as to why OpenFL's SWF Lite is sooooo slow compared to SWFTY display list, the two basically use individual bitmaps, so why is there such a huge discrepency? TextFields? GlowFilters? MovieClip class? mouseEnabled?

OpenFL 8.7.0 is also incredibly slow in html5 compared to 8.4.0, huge performance regression issue. Will send test to Granick to figure this out.

## Similar Projects

* [Flump](https://github.com/tconkling/flump), AIR-based approach focused on animation

## Copyright
Exporter powered by OpenFL

MIT license and copyright 2018 JD, blablabla
