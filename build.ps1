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
  -s http://mirrors.mit.edu/cygwin -g -P "git,cygport,gnupg,p7zip" | Where-Object `
  -FilterScript {$_ -notlike "Installing file *"} | Write-Output
& "C:\\cygbuild$bits\\bin\\sh" -lc "git clone git://git.suckless.org/sbase /usr/share/doc/sbase 2>&1 && \\
  cd /usr/share/doc/sbase && git checkout 9ab1478f1eb 2>&1 && make -j3 && \\
  git clone https://github.com/saitoha/libsixel /usr/share/doc/libsixel 2>&1 && \\
  cd /usr/share/doc/libsixel && git checkout 8c376f5ad03 2>&1 && ./configure && make -j3 && \\
  cd /usr/src/coreutils-* && \\
  sed -i 's/CYGCONF_ARGS=\`"/CYGCONF_ARGS=\`"--disable-nls /' coreutils.cygport && \\
  cygport coreutils.cygport all 2>&1 && cygcheck coreutils-*/inst/usr/bin/stty.exe && \\
  mkdir -p -v /usr/src/minicyg/bin && \\
  cp -v /bin/cygwin1.dll /bin/mintty.exe /usr/src/minicyg/bin && \\
  cp -v /bin/dash.exe /usr/src/minicyg/bin/sh.exe && \\
  cp -v /usr/share/doc/sbase/*.exe /usr/src/minicyg/bin && \\
  cp -v /usr/share/doc/libsixel/converters/img2sixel.exe /usr/src/minicyg/bin && \\
  cp -v /usr/src/coreutils-*/coreutils-*/inst/usr/bin/stty.exe /usr/src/minicyg/bin && \\
  for i in Cygwin mintty dash coreutils; do \\
    mkdir -p -v /usr/src/minicyg/share/doc/`$i && \\
    cp -v /usr/share/doc/`$i/COPYING /usr/src/minicyg/share/doc/`$i; \\
  done && \\
  for i in Cygwin mintty sbase libsixel; do \\
    mkdir -p -v /usr/src/minicyg/share/doc/`$i && \\
    cp -v /usr/share/doc/`$i/*LICENSE* /usr/src/minicyg/share/doc/`$i; \\
  done && \\
  cd /usr/src && 7z a minicyg-`$APPVEYOR_BUILD_NUMBER.zip minicyg && echo ok"
