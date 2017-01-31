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
  -s http://mirrors.mit.edu/cygwin -g -I -P "coreutils,make,gnupg" | Where-Object `
  -FilterScript {$_ -notlike "Installing file *"} | Write-Output
& "C:\\cygbuild$bits\\$setup" -q -n -R C:\\cygbuild$bits -l C:\\cygbuild$bits\\packages `
  -s http://mirrors.mit.edu/cygwin -g -P "git,cygport" | Where-Object `
  -FilterScript {$_ -notlike "Installing file *"} | Write-Output
& "C:\\cygbuild$bits\\bin\\sh" -lc "git clone git://git.suckless.org/sbase /usr/src/sbase && \\
  cd /usr/src/sbase && git checkout 9ab1478f1eb && make -j3 && \\
  git clone https://github.com/saitoha/libsixel /usr/src/libsixel && \\
  cd /usr/src/libsixel && git checkout 8c376f5ad03 && ./configure && make -j3 && \\
  cd /usr/src/coreutils-* && \\
  sed -i 's/CYGCONF_ARGS=\`"/CYGCONF_ARGS=\`"--disable-nls /' coreutils.cygport && \\
  cygport coreutils.cygport all && cygcheck coreutils-*/inst/usr/bin/stty.exe && \\
  cygcheck /usr/bin/stty.exe && mkdir -p /usr/src/minicyg/bin && \\
  cp /bin/cygwin1.dll /bin/mintty.exe /bin/dash.exe /usr/src/minicyg/bin && \\
  cp /usr/src/sbase/*.exe /usr/src/libsixel/converters/img2sixel.exe /usr/src/minicyg/bin && \\
  cp /usr/src/coreutils-*/inst/usr/bin/stty.exe /usr/src/minicyg/bin && \\
  for i in Cygwin mintty dash coreutils; do \\
    mkdir -p /usr/src/minicyg/share/doc/$i && \\
    cp /usr/share/doc/$i/COPYING /usr/src/minicyg/share/doc/$i && \\
    cp /usr/share/doc/$i/*LICENSE* /usr/src/minicyg/share/doc/$i; \\
  done && \\
  for i in sbase libsixel; do \\
    mkdir -p /usr/src/minicyg/share/doc/$i && \\
    cp /usr/src/$i/LICENSE* /usr/src/minicyg/share/doc/$i; \\
  done && echo ok"
