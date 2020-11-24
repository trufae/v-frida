frida_version=14.0.8
USE_WGET?=0

all: main

include frida.mk

main: $(FRIDA_SDK) main.v agent.v
	v -b js agent.v
	v main.v

.PHONY: main

