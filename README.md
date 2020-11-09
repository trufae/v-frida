v-frida
=======

This is the initial support of V for Frida.

V is a go-ish programming language that compiles to C and JS,
this makes it ideal to target Frida, so it's possible to
write host and target code using the same language.

The versatility of V and Frida, allow to write host and agent
code in both C or Javascript. Making possible to reuse your
nodejs host or agent scripts, or use CModule in the agent
without changing a line in your V host or agent code.

Status
------

The current code is at PoC level, so don't expect much

Example
-------

```
$ v -b js agent.v
$ v main.v
$ ./main
```

Host

```go
import frida.host
import os

fn main() {
	code := os.read_file('agent.js')?
	dm := host.new_device_manager()
	device := dm.get_device_by_type(.local)?
	pid := device.spawn('/usr/local/bin/r2', {
		argv: ['/usr/local/bin/r2']
	})?
	eprintln('ls: pid $pid')

	session := device.attach(pid)?
	script := session.create_script(code, {
		name: 'v-frida'
	})?

	script.load()?
	script.on_message(on_message)
	session.on_detached(on_detach)
	// do nothing
	script.unload()?
	device.kill(pid)
}
```

Agent:

```go
import frida.agent

fn on_message(mut stanza agent.Stanza, mut data agent.Data) {
	eprintln('message received! ${stanza.payload}')

	agent.recv(on_message)
}

fn main() {
	println('Hello world')
	agent.recv(on_message)
}
```

