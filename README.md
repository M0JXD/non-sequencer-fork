# Non Sequencer Fork

This is a fork of Non-Sequencer, inteneded as a sister project for Stazed's Non-XT forks.

The differences are:

+ Fixed errors to build with newer C++ standard. </br>
+ Changed to xmake build system. </br>
+ Change instrument directories.

### TODO:
+ Introduce some built-in humanisation options.
+ Add pure FLTK build.
+ Link against Stazed's FL and nonlib.

## Reasoning:

Stazed has no interest in maintaining a non-sequencer fork due to maintaining Seq32/Seq42.
However I wanted a sequencer with JACK-MIDI support, and a filterable "piano roll" for doing drums etc., which Non already has with it's instrument files.

I tried Seq66 but it was way too confusing for me and it's JACK-MIDI implementation was not what I wanted, automatically creating named output ports for other JACK-MIDI clients it detects instead of just providing "Seq66 MIDI Outs".

I also like Non's overall lightness as the only other options with JACK-MIDI I found are much heavier, those being MuSE (a whole DAW, which I don't need given I'm using Non-XT) and Hydrogen which can be set up to sequence. I did consider working on Aria Maestosa but that was on the other end of the scale being too simplistic.

## Dependencies
+ NTK (see below)
+ liblo-dev
+ libjack-jackd2-dev
+ libcairo-dev

### Getting NTK
Your distribution may have NTK available from the package manager. 
If not, grab it from Stazed's repo as it has some minor fixes.

### Building
First, ensure the dependencies are available. The are listed in xmake.lua under "add_links".

Then simply:

```
xmake
sudo xmake install
```

To build without native optimisations run this beforehand:
```
xmake f --NativeOptimizations=n -v
```

The included "instruments" folder is no longer in the home directory, but in:
```
/usr/local/share/non-sequencer/instruments
```
When it's implemented you will be able to add your own under:
```
~/.local/share/non-sequencer/instruments
```