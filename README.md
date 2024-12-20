# Non Sequencer Fork

This is a fork of Non-Sequencer, with some small maintenance fixes. 
This is not a serious project and should be considered "life support" as oppose to a serious forking attempt, although PRs (or making your own fork based on this) are welcome. It seems buggier than the original :(

The differences are:

+ Fixed some compile errors to build for newer C++ standard.
+ Changed to xmake build system.
+ Change instrument directory path.

### Would be nice to add:
+ Fix the bugs I've introduced (somehow 4/4 is ten beats to a bar now?)
+ Some built-in humanisation options.
+ Pure FLTK build, à la Stazed.
+ Link against Stazed's FL and nonlib.
+ An end user instrument directory, perhaps ~/.local/share/non-sequencer/instruments

## Reasoning:

I wanted a sequencer to go with Stazed's Non-XT with JACK-MIDI (yes, I'm aware of aj2midi) and NSM support, and a filterable "piano roll" for doing drums etc., which Non already has with it's instrument files. There are very few options with all these characteristics. Stazed has no interest in maintaining a non-sequencer fork due to maintaining Seq32/Seq42 which does not have JACK-MIDI. I tried Seq66 but it was way too confusing for me and it's JACK-MIDI implementation was not what I wanted, automatically creating named output ports for other JACK-MIDI clients it detects instead of just providing "Seq66 MIDI Outs". Seq192 is cool but leans more to live performance than arrangements. Even so, I'm not a big fan of the Seq24 piano roll.

The only other options with JACK-MIDI I found are much heavier, those being MuSE (a whole DAW and it's complicated to set up and use) and Hydrogen which can be set up to sequence. I did consider working on Aria Maestosa which had some preliminary JACK support added a while ago, but that was on the other end of the scale being too simplistic. Most everything else (https://wiki.linuxaudio.org/apps/notation_apps, https://wiki.linuxaudio.org/apps/midi_apps) is either the wrong tool or long abandoned. So I decided to go back and try Non.

The .deb on KXStudio refused to pick up instrument files, so I knew I needed to fix that from source. Upon trying to build Non-Sequencer I hit various issues due to outdated waf, not being able to find libraries, and compile errors due to outdated coding standard. So I fixed those issues by porting to build system that shouldn't go out of date as quickly but is still easy to use, and doing some minor code edits.

At the moment I'm weighing up whether to keep working on this, or look at trying to add NSM and better JACK support to something else (I quite like Helio Sequencer), and continuing to use Hydrogen for drums. Or maybe even reviving one of the many abandoned sequencers in the Linux Audio Wiki - I've yet to try/test everything!

Another reason is that I mentioned looking into NTK maintenance for the Non-XT series, so it's worth having some (passing) experience.

## Dependencies (Debian names)
+ NTK (see below)
+ liblo-dev
+ libjack-jackd2-dev
+ libcairo-dev

### Getting NTK
Your distribution may have NTK available from the package manager. 
If not, grab it from Stazed's repo as it has some minor fixes.

### Building
First, ensure the dependencies are available, as well as the xmake build system.
Then simply:

```
xmake
xmake install --admin
```

The included "instruments" folder is no longer in the home directory, but in:
```
/usr/local/share/non-sequencer/instruments
```
