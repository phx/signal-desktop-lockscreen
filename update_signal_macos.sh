#!/bin/bash

cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

if ! command -v brew 2>&1 > /dev/null; then
  echo 'homebrew must be installed.' && exit
fi
brew install git git-lfs nvm

BRANCH="$(curl -skL 'https://api.github.com/repos/signalapp/Signal-Desktop/releases/latest' | grep tarball_url | awk -F '": "' '{print $NF}' | sed 's/",$//' | awk -F '/' '{print $NF}' | sed -E 's/v([0-9]+\.[0-9]+\.)[0-9]+/\1x/')"
sudo rm -rf "$HOME/.signal-desktop"
git clone --single-branch --branch 5.15.x https://github.com/signalapp/Signal-Desktop "$HOME/.signal-desktop" || exit 1
cd "$HOME/.signal-desktop" || exit 1

. "/usr/local/opt/nvm/nvm.sh"
nvm install "$(cat .nvmrc)"
nvm use
git-lfs install &&\
npm install --global yarn &&\
sudo yarn install --frozen-lockfile || exit 1

if uname -a | grep -q Darwin >/dev/null 2>&1; then
  MAC=1
else
  MAC=0
fi

if [ $MAC -eq 1 ]; then
  SIGNAL_DIR="/Applications/Signal.app/Contents/Resources"
  PASSWD_KEY="$HOME/Library/Application Support/Signal/.lockkey"
  #sed -E 's@<key>AsarIntegrity</key><string>.*&#34;}}</string><key>@<key>@g' "${SIGNAL_DIR}/../Info.plist" > tmp &&\
  #mv tmp "${SIGNAL_DIR}/../Info.plist"
  #sudo chown "${LOGNAME}:admin" "${SIGNAL_DIR}/../Info.plist"
else
  SIGNAL_DIR="/opt/Signal/resources"
  PASSWD_KEY="$HOME/.config/Signal/.lockkey"
fi

if [ ! -d "$SIGNAL_DIR" ]; then
  mkdir -p "$SIGNAL_DIR"
fi

curl -fskSLo js/lockscreen.js 'https://raw.githubusercontent.com/phx/signal-desktop-lockscreen/master/lockscreen.template.js'

if ! grep -q 'lockscreen.js' background.html >/dev/null 2>&1; then
  IFS=''
  while read -r line; do
    if echo "$line" | grep -q "</body>" >/dev/null 2>&1; then
      #echo -e "$line"
      echo -e "  <script type='text/javascript' src='js/lockscreen.js'></script>"
      echo -e "$line"
    else
      echo -e "$line"
    fi
  done < "background.html" > "tmp" &&\
  mv tmp background.html
fi
sed "s@\*\*\*LOCK_KEY_FILE_HERE\*\*\*@${PASSWD_KEY}@" "js/lockscreen.js" > "tmp" &&\
mv tmp js/lockscreen.js

pass_prompt() {
  echo -e "\nThe following password file will be stored at $PASSWD_KEY:\n"
  read -r -s -p 'Please type the passphrase you wish to use to unlock Signal: ' PASS1
  echo
  read -r -s -p 'Please re-type the password for verification: ' PASS2
  echo
  if [ "$PASS1" != "$PASS2" ]; then
    echo "Passwords do not match."
    pass_prompt
  else
    echo "$PASS1" > "$PASSWD_KEY"
  fi
}

if [ ! -f "$PASSWD_KEY" ]; then
  pass_prompt
fi

sudo yarn grunt &&\
sudo yarn build:webpack &&\
sudo yarn test &&\
sudo yarn build-release || exit 1

echo -e '\nRestarting Signal...'
if [ $MAC -eq 1 ]; then
  osascript -e 'Tell application "Signal" to quit'
  sleep 5
  sudo chown -R "$LOGNAME" release/mac/Signal.app
  sudo rm -rf /Applications/Signal.app
  sudo mv release/mac/Signal.app /Applications/
  open "/Applications/Signal.app"
else
  pkill signal-desktop
  sleep 5
  (signal-desktop &) >/dev/null 2>&1
fi

echo -e '\nDone.\n'

