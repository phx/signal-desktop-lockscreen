![Platform: Linux/MacOS](https://img.shields.io/badge/platform-Linux%2FMacOS-blue)
![Requirements: Linux/MacOS](https://img.shields.io/badge/requirements-npm-blue)
![Follow me on Twitter](https://img.shields.io/twitter/follow/rubynorails?label=follow&style=social)
![Tweet about this Project](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2Fphx%2Fsignal-desktop-lockscreen)

![signal-desktop-lockscreen](./animation.gif?raw=true)

# signal-desktop-lockscreen

```
git clone https://github.com/phx/signal-desktop-lockscreen
cd signal-desktop-lockscreen
./signal_lockscreen_patcher.sh
```

Run this script to patch your Signal Desktop installation to support an application lockscreen, and activate the lockscreen with <kbd>Ctrl</kbd> + <kbd>L</kbd>.

It runs 5 seconds after Signal starts in order to allow your messages to load, and can later be invoked again like above by the <kbd>Ctrl</kbd> + <kbd>L</kbd> keyboard shortcut.

This interactive script will prompt you for a password that will be stored in your Signal configuration directory.

You will need to run this patch every time Signal Desktop is updated in order to keep it active.

## Details

I have already submitted [Pull request #4439](https://github.com/signalapp/Signal-Desktop/pull/4439) to the Signal development branch, which implements a pseudo lockscreen functionality by locking with <kbd>Ctrl</kbd> + <kbd>L</kbd>
and unlocking with either <kbd>Ctrl</kbd> + <kbd>;</kbd> or <kbd>Ctrl</kbd> + <kbd>'</kbd>.

The reason I have not submitted this as an official pull request is because it requires more serverside interaction than I am familiar with and would have to be implemented in Node.js rather than clientside
JavaScript.  It's a great functionality and works perfectly for my use cases.  Please inspect the code before running it in order to assure yourself that it's not doing anything malicious, as Signal
is a very sensitive and private application that we want to keep sensitive and private.

If [Pull request #4439](https://github.com/signalapp/Signal-Desktop/pull/4439) ever gets approved and merged into the official Signal Desktop master branch, I have made sure that this patch continues to work when applied.
Instead of having a pseudo-lockscreen with <kbd>Ctrl</kbd> + <kbd>L</kbd>, you will have an actual functioning lockscreen with password integration, which this patch provides.
