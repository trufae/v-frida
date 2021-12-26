frida_version=14.0.8
USE_WGET?=0

all: main

include frida.mk

main: $(FRIDA_SDK) main.v agent.v
	#v -o examples/target examples/target.v
	#v -b js_freestanding agent.v
	v -g main.v
	./main

fmt indent:
	v fmt -w . frida

.PHONY: main

