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
& "C:\\cygbuild$bits\\$setup" -q -n -R C:\\cygbuild$bits -l C:\\cygbuild$bits\\packages `
  -s http://mirrors.mit.edu/cygwin -g -I -P "git,cygport,coreutils" | Where-Object `
  -FilterScript {$_ -notlike "Installing file *"} | Write-Output
& "C:\\cygbuild$bits\\bin\\sh" -lc "echo ok && \\
  ls -al /usr/src"
