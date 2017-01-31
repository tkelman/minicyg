# change the following to 32 for 32 bit cygwin
$bits = "64"
$arch = "x86_$bits".Replace("x86_32", "i686")
$setup = "setup-$arch.exe".Replace("i686", "x86")

if (Test-Path "C:\\cygbuild$bits") {
  rm -Recurse -Force C:\\cygbuild$bits
}
mkdir -Force C:\\cygbuild$bits | Out-Null
(new-object net.webclient).DownloadFile(
  "http://cygwin.com/$setup", "C:\\cygbuild$bits\\$setup")
# TODO: use cygwin time machine for build reproducibility
# download sources (-I) for coreutils and make
# (maybe apt-cyg could be used to avoid downloading -src for the entire base system?)
& "C:\\cygbuild$bits\\$setup" -q -n -R C:\\cygbuild$bits -l C:\\cygbuild$bits\\packages `
  -s http://mirrors.mit.edu/cygwin -g -I -P "coreutils,make" | Where-Object `
  -FilterScript {$_ -notlike "Installing file *"} | Write-Output
& "C:\\cygbuild$bits\\$setup" -q -n -R C:\\cygbuild$bits -l C:\\cygbuild$bits\\packages `
  -s http://mirrors.mit.edu/cygwin -g -P "git,cygport" | Where-Object `
  -FilterScript {$_ -notlike "Installing file *"} | Write-Output
& "C:\\cygbuild$bits\\bin\\sh" -lc "git clone git://git.suckless.org/sbase && \\
  cd sbase && make -j3 && git clone https://github.com/saitoha/libsixel ../libsixel && \\
  cd ../libsixel && ./configure && make -j3 && cd /usr/src/coreutils-* && \\
  sed -i 's/CYGCONF_ARGS=\"/CYGCONF_ARGS=\"--disable-nls /' coreutils.cygport && \\
  cygport coreutils.cygport all && echo ok"
