![signal-desktop-lockscreen](./animation.gif?raw=true)

# signal-desktop-lockscreen

**Requirements:**
- `npm`

**Supported Operating Systems:**
- Linux
- MacOS

Run this script to patch your Signal Desktop installation to support an application lockscreen, activated with Ctrl+L.

It runs 5 seconds after Signal starts in order to allow your messages to load, and can later be invoked with Ctrl+L.

This interactive script will prompt you for a password that will be stored in your Signal configuration directory.

You will need to run this patch every time Signal Desktop is updated in order to keep it active.

## Details

I have already submitted [Pull request #4439](https://github.com/signalapp/Signal-Desktop/pull/4439) to the Signal development branch, which implements a pseudo lockscreen functionality by locking with `Ctrl+L`
and unlocking with either `Ctrl+;` or `Ctrl+'`.

The reason I have not submitted this as an official pull request is because it requires more serverside interaction than I am familiar with and would have to be implemented in Node.js rather than clientside
JavaScript.  It's a great functionality and works perfectly for my use cases.  Please inspect the code before running it in order to assure yourself that it's not doing anything malicious, as Signal
is a very sensitive and private application that we want to keep sensitive and private.
