frida_version=14.0.5
USE_WGET?=0

a: all

include frida.mk

all: $(FRIDA_SDK)
	v -b js agent.v
	v main.v

