# Aegisub

For binaries and general information [see the homepage](http://www.aegisub.org).

The bug tracker can be found at http://devel.aegisub.org.

Support is available on [the forums](http://forum.aegisub.org) or [on IRC](irc://irc.rizon.net/aegisub).

## Building Aegisub

### macOS

Currently only macOS tested.
```
cmake -B build
cmake --build build
```
Key cmake configure options:

* `WX_CONFIG=/your/path/of/wx-config`: specify the wx-config you will use
* `WITH_LOCAL_WXWIDGETS`: download and build wxWidgets automatically
* `ICU_ROOT=/your/path/of/icu/install`: speicify the icu4c installed path
* `WITH_LOCAL_ICU`: download and build icu4c automatically
* `WITH_LOCAL_BOOST`: download and build boost automatically
* `LUAJIT_ROOT=/your/path/of/luajit/install`: specify the luajit installed path
* `WITH_LOCAL_LUAJIT`: download and build luajit automatically
* `WITH_LOCAL_ICONV`: download and build iconv automatically
* `WITH_LOCAL_ASS`: download and build libass automatically
