# Non Sequencer Fork

This is a fork of Non-Sequencer, with some small maintenance fixes. 
This is not a serious project and should be considered "life support" as oppose to a serious forking attempt, although PRs (or making your own fork based on this) are welcome.

The differences are:

+ Fixed some compile errors to build for newer C++ standard.
+ Changed to xmake build system.
+ Change instrument directory path to /usr/local/share/non-sequencer/instruments
+ NSM Optional GUI
  + This can be completely removed with a build option, see below.
  + By creating a file called "force_show" (its contents do not matter) in the ~/.non directory the hidden by default startup behaviour can be overridden. 
+ Save the window size
  + Currently, this is saved for all instances under ~/.non/window, saving per project is not implemented and will not be until someone either provides a good reason to or submits the code.
  + It is only implemented in optional-gui builds.
+ Link against @Stazed 's nonlib and FL

### Would be nice to do/fix:
+ Pure FLTK build, à la Stazed.
+ An end user instrument directory, perhaps ~/.local/share/non-sequencer/instruments
+ Fix some bugs: 
1) If there is a note already to the right of where you want to place one the sequencer might not allow you to place it. To work around this, remove the note(s) to the right, then enter them again afterwards. Alternatively you can choose a shorter note duration to maintain a gap to the right of the entered note. (This is a carry over from OG Non)
2) With the Default intrument, scrolling down can cause the labels to become misaligned. To workaround, it seems that selecting the instrument twice disables scrolling. (Can't test in OG Non, see below)
3) Some crashes when something else tries to control JACK transport whilst sequencer is timebase master (I rarely uses master mode so this is not urgent for me)

## Reasoning for fork:

I wanted a sequencer to go with Stazed's Non-XT with JACK-MIDI (yes, I'm aware of a2jmidi), NSM support, and a filterable "piano roll" for doing drums etc. There are very few options with all these characteristics, Non being one of them.

When I tried the Non-Sequencer .deb on KXStudio it refused to pick up instrument files, so I knew I needed to fix that from source. Upon trying to build Non-Sequencer I hit various issues due to outdated waf, not being able to find libraries, and compile errors due to outdated coding standard. So I fixed those issues by porting to build system that shouldn't go out of date as quickly but is still easy to use, and doing some minor code edits.

At the moment I'm weighing up whether to keep working on this, or look at trying to add NSM and better JACK support to something else.
Another reason is that I mentioned looking into NTK maintenance for the Non-XT series, so it's worth having some (passing) experience.

## Dependencies (Debian names)
+ NTK (see below)
+ liblo-dev
+ libjack-jackd2-dev
+ libcairo-dev

### Getting NTK
Your distribution may have NTK available from the package manager. 
If not, build it from linuxaudios's backup mirror, or from Stazed's NTK-UNOFFICIAL repo as it has some great fixes/improvements.

### Building
First, ensure the dependencies are available, as well as the xmake build system.

Before anything you will need to get the nonlib and FL submodules. Do this by:
```
git submodule update --init
```

Then build by calling xmake:

```
xmake
```

It can then be installed to your system with:

```
xmake install --admin
```

To build without the hidden GUI feature, run this before calling xmake:
```
xmake f --HideGUI=n -v
```
