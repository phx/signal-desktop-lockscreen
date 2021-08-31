![Platform: ALL](https://img.shields.io/badge/platform-ALL-green)
![Requirements: Linux/MacOS](https://img.shields.io/badge/requirements-npm-blue)
![Follow me on Twitter](https://img.shields.io/twitter/follow/rubynorails?label=follow&style=social)
![Tweet about this Project](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2Fphx%2Fsignal-desktop-lockscreen)

![signal-desktop-lockscreen](./animation.gif?raw=true)

# signal-desktop-lockscreen

#### WARNING: This breaks functionality on MacOS as of Signal Desktop v5.15.0! (If you have a fix, submit a PR)

*In the meantime, I have created a script specifically for Mac that can be run manually anytime you are notified of an available Signal Desktop update.*

It requires `homebrew` to ALREADY be installed:

```
git clone https://github.com/phx/signal-desktop-lockscreen
cd signal-desktop-lockscreen
sudo cp update_macos_macos.sh /usr/local/bin/update_signal
update_signal
```

This basically installs Signal from source with the lockscreen code already in place.

*To test to see if the previous (and much easier version) still works on Linux and Windows, here are the old directions:*

Run this script to patch your Signal Desktop installation to support an application lockscreen, and activate the lockscreen with <kbd>Ctrl</kbd> + <kbd>L</kbd>.

It runs 5 seconds after Signal starts in order to allow your messages to load, and can later be invoked again like above by the <kbd>Ctrl</kbd> + <kbd>L</kbd> keyboard shortcut.

This interactive script will prompt you for a password that will be stored in your Signal configuration directory.

You will need to run this patch every time Signal Desktop is updated in order to keep it active.

## Linux/MacOS instructions

```
git clone https://github.com/phx/signal-desktop-lockscreen
cd signal-desktop-lockscreen
./signal_lockscreen_patcher.sh
```

## Windows instructions

- Clone the repository, or download as a zip file.
  - If you download as a zip file, unzip the repository, and navigate to the unzipped folder.
- Double-click [`signal_lockscreen_patcher.bat`](./signal_lockscreen_patcher.bat), and once the script finishes, you are good to go.

## Details

I previously submitted [Pull request #4439](https://github.com/signalapp/Signal-Desktop/pull/4439) to the Signal development branch, which implements a pseudo lockscreen functionality by locking with <kbd>Ctrl</kbd> + <kbd>L</kbd>
and unlocking with either <kbd>Ctrl</kbd> + <kbd>;</kbd> or <kbd>Ctrl</kbd> + <kbd>'</kbd>, but that PR got denied because it didn't meet security standards and was not considered a "full feature" -- specifically -- this was the 
exact response that I received:

*"Thank you for the pull request, while this is an artful solution to the lock-screen issue it doesn't fully satisfy the requirements for security. We would also need some design resources on this to fully implement screen lock."*

The reason I have not submitted the full functionality displayed in this patch as an official pull request is because it would require full  serverside implementation via Node.js, and I am simply not familiar enough with the idosyncracies
of the source code at this point in order to allow me to develop that functionality on my own. Thus, I have resulted to the serverside set up via the patch script, and clientside implementation in JavaScript.

It's a great functionality and works perfectly for my use cases.  Please inspect the code before running it in order to assure yourself that it's not doing anything malicious, as Signal
is a very sensitive and private application that we want to keep sensitive and private.

It should be known that it is possible to launch Developer Tools within Signal and retrieving the plain-text password via inspecting the network response.  That is because this is inteded as more of a privacy feature than a security
feature.  It will not stop anyone who already has access to your computer from accessing your messages if they know their way around.

Hopefully in the future, the Signal Desktop development team will implement this as a fully-functioning native feature and use backend calls for your PIN as the passcode, or either encrypt a passphrase that you set somewhere in the menu
options, or at least store the password hash in the local database to implement serverside checks rather than the clientside checks that I have implemented.  This would end up satisfying the security requirements.  However, until that
day comes, by running this patch every time you update signal, you will have a fully-functional lockscreen as an additional privacy feature.

I did what I could, guys.  It's enough for me for now until someone figures out how to implement this in the native Signal Desktop code.
