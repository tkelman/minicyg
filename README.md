# minicyg
Minimalist repackaged subset of Cygwin. This currently contains:
  - `cygwin1.dll` the core POSIX emulation layer used by Cygwin and MSYS2, [LGPLv3 licensed](https://cygwin.com/licensing.html)
  - `cygwin-console-helper.exe` suppresses extra console popups, [LGPLv3 licensed](https://cygwin.com/licensing.html)
  - `mintty.exe` a lightweight terminal emulator, [GPLv3 licensed](https://github.com/mintty/mintty/blob/master/LICENSE)
  - `dash.exe` a small POSIX shell, [BSD-3 licensed (mostly)](http://git.kernel.org/cgit/utils/dash/dash.git/tree/COPYING)
  - the suckless sbase coreutils implementation, [MIT licensed](http://git.suckless.org/sbase/tree/LICENSE)
  - `img2sixel.exe` from libsixel to play around with sixel graphics, [MIT licensed](https://github.com/saitoha/libsixel/blob/master/LICENSE)
  - `stty.exe` from GNU coreutils compiled with internationalization support disabled, [GPLv3 licensed](https://github.com/coreutils/coreutils/blob/master/COPYING)

This is intentionally tiny and has no package manager. If you want one of those
for a POSIX environment on Windows, you should probably use Cygwin or MSYS2.
If you just want coreutils and a shell (that can do tab completion, unlike dash),
try [busybox-w32](https://frippery.org/busybox/) instead.

The build script in this repository is [MIT licensed](LICENSE), but the binaries
are an aggregation of the above components. If you know of permissively-licensed
replacements that provide equivalent functionality for any of the above
GPL-licensed pieces, open an issue and let me know.
