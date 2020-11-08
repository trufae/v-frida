v-frida
=======

This is the initial support of V for Frida.

V is a go-ish programming language that compiles to C and JS,
this makes it ideal to target Frida, so it's possible to
write host and target code using the same language.

Status
------

The current code is at PoC level, so don't expect much

Example
-------

Host

```go
import frida

const (
	code = $embed('agent.js')
)

fn main() {
	dm := frida.new_device_manager()
	device := dm.get_device_by_type_sync (frida.device_type_usb) or {
		panic (err)
	}
	session := device.attach_sync (pid) or {
		panic(err)
	}
	script := session.create_script_sync(code) or {
		panic(err)
	}
	script.on_message(on_message)
	session.on_detached(on_detach)

	script.load_sync() or {
		panic(err)
	}
}
```

Agent:

```go
import frida

fn on_message(mut stanza frida.Stanza, mut data frida.Data) {
	eprintln('message received! ${stanza.payload}')
	frida.send('message!')
	frida.recv(on_message)
}

fn main() {
	println('Hello world')
	frida.recv(on_message)
}

```

