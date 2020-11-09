ifeq ($(strip $(frida_os)),)
ifeq ($(shell uname -o 2> /dev/null),Android)
frida_os := android
else
frida_os := $(shell uname -s | tr '[A-Z]' '[a-z]' | sed 's,^darwin$$,macos,')
endif
endif
frida_arch := $(shell uname -m | sed -e 's,i[0-9]86,x86,g' -e 's,armv7l,arm,g' -e 's,aarch64,arm64,g')
frida_os_arch := $(frida_os)-$(frida_arch)

WGET?=wget
CURL?=curl

FRIDA_SDK=ext/frida-$(frida_os)-$(frida_version)/libfrida-core.a
FRIDA_SDK_URL=https://github.com/frida/frida/releases/download/$(frida_version)/frida-core-devkit-$(frida_version)-$(frida_os_arch).tar.xz
FRIDA_CPPFLAGS+=-Iext/frida
ifeq ($(frida_os),android)
FRIDA_LIBS+=ext/frida/libfrida-core.a
else
FRIDA_LIBS+=ext/frida/libfrida-core.a -lresolv
endif

# OSX-FRIDA
ifeq ($(shell uname),Darwin)
LDFLAGS+=-Wl,-exported_symbol,_radare_plugin
  ifeq ($(frida_os),macos)
FRIDA_LDFLAGS+=-Wl,-no_compact_unwind
FRIDA_LIBS+=-framework Foundation
  endif
  ifeq ($(frida_os),ios)
FRIDA_LIBS+=-framework UIKit
FRIDA_LIBS+=-framework CoreGraphics
  else
  ifeq ($(frida_os),macos)
FRIDA_LIBS+=-lbsm
endif
  endif
  ifeq ($(frida_os),macos)
FRIDA_LIBS+=-framework AppKit
  endif
endif

ifeq ($(frida_os),android)
LDFLAGS+=-landroid -llog -lm
STRIP_SYMBOLS=yes
endif

ifeq ($(STRIP_SYMBOLS),yes)
LDFLAGS+=-Wl,--version-script,ld.script
LDFLAGS+=-Wl,--gc-sections
endif
LDFLAGS+=-Wl,-dead_strip

$(FRIDA_SDK):
	rm -f ext/frida
	mkdir -p $(@D)/_
ifeq ($(USE_WGET),1)
	$(WGET) -cO frida-sdk.tar.xz $(FRIDA_SDK_URL)
	tar xJvf frida-sdk.tar.xz -C $(@D)/_
else
	curl -Ls $(FRIDA_SDK_URL) | xz -d | tar -C $(@D)/_ -xf -
endif
	mv $(@D)/_/* $(@D)
	rmdir $(@D)/_
	#mv ext/frida ext/frida-$(frida_os)-$(frida_version)
	cd ext && ln -fs frida-$(frida_os)-$(frida_version) frida

frida.pc:
	echo $(FRIDA_CPPFLAGS)
	echo $(FRIDA_LIBS)
