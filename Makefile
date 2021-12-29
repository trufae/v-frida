frida_version=14.0.8
USE_WGET?=0

all: main

include frida.mk

main: $(FRIDA_SDK) main.v
	v -g main.v
	./main

fmt indent:
	v fmt -w main.v agent.v frida

.PHONY: main

