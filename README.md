# mixtery

A simple music player with less repetetive shuffling.

## Introduction

This is shared in the hope that it may be useful to somebody else.

Unfortunately the code has been neglected, and at this point will likely need
work to make it run again. It targets an old version of Swift and probably old
APIs, and hasn't been tested in a few years.

For what it's worth, the last time I visited the project it was working well
enough for my wife to use as her primary player.

Please enjoy and share freely. I would love to hear about anything that gets
built with it. Contact me at mixtery@wijjo.com.

I might also suggest double checking that the included resources are free
to redistribute. I believe I chose ones that were not restricted. But since it's
been a long time it wouldn't hurt to make extra sure that it is still true.

## The shuffle algorithm

Apple's shuffle algorithm is a simple random selection that makes no attempt to
avoid repetition. It does not care what came before.

This algorithm deals with the music collection as a pool, from which one track
at a time is chosen, played, and not available again until the pool is exhausted.
