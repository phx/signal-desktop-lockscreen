#!/bin/bash

if echo "$1" | grep -q 'mac' >/dev/null 2>&1; then
  MAC=1
else
  MAC=0
fi

if [ $MAC -eq 1 ]; then
  SIGNAL_DIR="/Applications/Signal.app/Contents/Resources"
  PASSWD_KEY="$HOME/Library/Application Support/Signal/.lockkey"
else
  SIGNAL_DIR="/opt/Signal/resources"
  PASSWD_KEY="$HOME/.config/Signal/.lockkey"
fi

if ! command -v npm >/dev/null 2>&1; then
  echo 'This patch requires npm to be installed' & exit
fi
if ! command -v asar >/dev/null 2>&1; then
  npm install -g asar
fi

sudo cp -r "${SIGNAL_DIR}/app.asar" .
sudo chown "$LOGNAME" app.asar
asar extract app.asar app.asar.unpacked

IFS=''
while read -r line; do
  if echo "$line" | grep -q "src='js/wall_clock_listener.js'>" >/dev/null 2>&1; then
    echo -e "$line"
    echo -e "  <script type='text/javascript' src='js/lockscreen.js'></script>"
  else
    echo -e "$line"
  fi
done < "app.asar.unpacked/background.html" > "background.html"
mv background.html "app.asar.unpacked"/
sed "s@\*\*\*LOCK_KEY_FILE_HERE\*\*\*@${PASSWD_KEY}@" "lockscreen.template.js" > "app.asar.unpacked/js/lockscreen.js"

asar pack app.asar.unpacked app.asar
sudo mv app.asar "$SIGNAL_DIR"/

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

pass_prompt

if [ $MAC -eq 1 ]; then
  osascript -e 'Tell application "Signal" to quit'
  sleep 5
  open "/Applications/Signal.app"
else
  pkill signal-desktop
  sleep 5
  (signal-desktop &) >/dev/null 2>&1
fi

rm -rf app.asar.unpacked
