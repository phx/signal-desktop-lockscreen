// eslint-disable-next-line func-names
var lockKeyFile = '***LOCK_KEY_FILE_HERE***';

function ready(callback){
    // in case the document is already rendered
    if (document.readyState!='loading') callback();
    // modern browsers
    else if (document.addEventListener) document.addEventListener('DOMContentLoaded', callback);
    // IE <= 8
    else document.attachEvent('onreadystatechange', function(){
        if (document.readyState=='complete') callback();
    });
}

function displayLockScreen() {
  var div = document.createElement("div");
  div.setAttribute("id", "lockscreen");
  div.style.position = "absolute";
  div.style.top = "0";
  div.style.right = "0";
  div.style.bottom = "0";
  div.style.left = "0";
  div.style.height = "100%";
  div.style.width = "100%";
  div.style.margin = "0 auto";
  div.style["text-align"] = "center";
  div.style.background = "#2e2e2e";
  div.style.display = "block";
  div.style["z-index"] = "9999999";
  div.style.color = "#ffffff";
  div.innerHTML = '<center><img style="margin-top: 20%;" src="./images/icon_128.png"/><h3>Signal is locked.</h3><form action="" method="get" name="lockscreen_form" id="lockscreen_form"><input type="password" name="password" id="password" placeholder="Enter passphrase to unlock."></textarea><input type="submit" style="display:none" /></form></center>';
  document.body.appendChild(div)
  keybox = document.getElementById("password");
  keybox.style.background = "#121212";
  keybox.style["border-color"] = "#121212";
  keybox.style.color = "#ffffff";
  keybox.style["font-size"] = "1em";
  keybox.style["font-family"] = '"Lucida Console", Monaco, "Courier New", Courier, monospace';
  //keybox.style["font-weight"] = "bold";
  keybox.style.margin = "0";
  keybox.style.padding = "13px 13px 10px 10px";
  keybox.style.width = "300px";
  keybox.style.resize = "none";
  keybox.style["text-align"] = "center";
  keybox.style["-webkit-border-radius"] = "10px";
  keybox.style["-moz-border-radius"] = "10px";
  keybox.style["border-radius"] = "10px";
}

ready(function() {
  setTimeout(() => { displayLockScreen(); }, 5000);
});

document.onkeyup = function(lockscreen) {
  if (lockscreen.ctrlKey && lockscreen.which == 76) {
    document.lockscreen_form.reset();
    document.getElementById("lockscreen").style.display = "block";
  }
  if (lockscreen.which == 13) {
    var div = document.getElementById("lockscreen");
    if (div.style.display == "block") {
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
          var status = xhr.status;
          if (status === 0 || (status >= 200 && status < 400)) {
            var lockkey = xhr.responseText.replace(/(\r\n|\n|\r)/gm, "");
            var keybox = document.getElementById("password");
            if (keybox.value == lockkey) {
              div.style.display = "none";
            }
          }
        }
      }
      xhr.open('GET', lockKeyFile);
      xhr.send();
    }
  }
};
