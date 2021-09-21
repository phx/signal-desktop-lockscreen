#!/bin/bash

cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

if uname -a | grep -q Darwin >/dev/null 2>&1; then
  MAC=1
else
  MAC=0
fi

if [ $MAC -eq 1 ]; then
  SIGNAL_DIR="/Applications/Signal.app/Contents/Resources"
  PASSWD_KEY="$HOME/Library/Application Support/Signal/.lockkey"
  sed -E 's@<key>AsarIntegrity</key><string>.*&#34;}}</string><key>@<key>@g' "${SIGNAL_DIR}/../Info.plist" > tmp &&\
  mv tmp "${SIGNAL_DIR}/../Info.plist"
  sudo chown "${LOGNAME}:admin" "${SIGNAL_DIR}/../Info.plist"
else
  SIGNAL_DIR="/opt/Signal/resources"
  PASSWD_KEY="$HOME/.config/Signal/.lockkey"
fi

if [ ! -d "$SIGNAL_DIR" ]; then
  echo "No Signal Desktop installation was found" & exit
fi

if ! command -v npm >/dev/null 2>&1; then
  echo 'This patch requires npm to be installed' & exit
fi
if ! command -v asar >/dev/null 2>&1; then
  npm install -g asar
fi

sudo cp -r "${SIGNAL_DIR}/app.asar" "${SIGNAL_DIR}/app.asar.bak"
sudo cp -r "${SIGNAL_DIR}/app.asar.unpacked" "${SIGNAL_DIR}/app.asar.unpacked.bak"
sudo cp -r "${SIGNAL_DIR}/app.asar" .
sudo cp -r "${SIGNAL_DIR}/app.asar.unpacked" .
sudo rm -rf "${SIGNAL_DIR}/app.asar" "${SIGNAL_DIR}/app.asar.unpacked"
sudo chown "$LOGNAME" app.asar
sudo chown -R "$LOGNAME" app.asar.unpacked
asar extract app.asar app

if ! grep -q 'lockscreen.js' app/background.html >/dev/null 2>&1; then
  IFS=''
  while read -r line; do
    #if echo "$line" | grep -q "src='js/wall_clock_listener.js'>" >/dev/null 2>&1; then
    if echo "$line" | grep -q "</body>" >/dev/null 2>&1; then
      #echo -e "$line"
      echo -e "  <script type='text/javascript' src='js/lockscreen.js'></script>"
      echo -e "$line"
    else
      echo -e "$line"
    fi
  done < "app/background.html" > "background.html"
  mv background.html app/
fi
sed "s@\*\*\*LOCK_KEY_FILE_HERE\*\*\*@${PASSWD_KEY}@" "lockscreen.template.js" > "app/js/lockscreen.js"

#asar pack app.asar.unpacked app.asar
sudo mv app "$SIGNAL_DIR"/
sudo mv app.asar.unpacked "$SIGNAL_DIR"/
if [ $MAC -eq 1 ]; then
  sudo xattr -cr /Applications/Signal.app
fi

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

echo -e '\nRestarting Signal...'
if [ $MAC -eq 1 ]; then
  osascript -e 'Tell application "Signal" to quit'
  sleep 5
  open "/Applications/Signal.app"
else
  pkill signal-desktop
  sleep 5
  (signal-desktop &) >/dev/null 2>&1
fi

rm -rf app.asar app
echo -e '\nDone.\n'

