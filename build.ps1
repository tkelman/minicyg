# change the following to 32 for 32 bit cygwin
$bits = "64"
$arch = "x86_$bits".Replace("x86_32", "i686")
$setup = "setup-$arch.exe".Replace("i686", "x86")

ls C:\\

mkdir -Force C:\\cygwin$bits | Out-Null
(new-object net.webclient).DownloadFile(
  "http://cygwin.com/$setup", "C:\\cygwin$bits\\$setup")
& "C:\\cygwin$bits\\$setup" -q -n -R C:\\cygwin$bits -l C:\\cygwin$bits\\packages `
  -s http://mirrors.mit.edu/cygwin -g -P "make,gcc,cygport" | Where-Object `
  -FilterScript {$_ -notlike "Installing file *"} | Write-Output
& "C:\\cygwin$bits\\bin\\sh" -lc "echo ok && \\
  echo ok"
