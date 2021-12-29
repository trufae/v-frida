# v-frida

This is the initial support of V for Frida.

V is a go-ish programming language that compiles to C and JS,
this makes it ideal to target Frida, so it's possible to
write host and target code using the same language.

The versatility of V and Frida, allow to write host and agent
code in both C or Javascript. Making possible to reuse your
nodejs host or agent scripts, or use CModule in the agent
without changing a line in your V host or agent code.

## Status

This is the list of checkbox to mark over time

* [x] Spawn local apps
* [x] Attach local/usb by pid
* [x] Trace methods (onEnter/onLeave)
* [x] Change return value onLeave
* [x] Enumerate modules, symbols and exports
* [ ] Attach via USB by appname
* [ ] Change argument values onEnter
* [ ] Enumerate processes

## Example

This is a simplified example usage for the host and agent side in pure V

### Host

```v
import frida.host
import os

fn load_agent() string {
	os.system('v -o agent.js agent.v')
	return os.read_file('agent.js')?
}

fn watchdog() ? {
	time.sleep(10 * 100000)
}

fn main() {
	dm := host.new_device_manager()
	device := dm.get_device_by_type(.local)?
	pid := device.spawn('/usr/local/bin/r2', {})?
	eprintln('ls: pid $pid')

	session := device.attach(pid)?
	session.on_detached(host.SessionDetachCallback(on_detached), voidptr(0))

	code := load_agent()
	script := session.create_script(code, {
		name: 'v-frida'
		on_message: host.ScriptMessageCallback(on_message)
		user_data: 0
	})?

	script.load()?
	fill := go watchdog(fs)
	fill.wait() or { eprintln('Oops: $err') }
	script.unload()?
	device.kill(pid)
}
```

### Agent:

```v
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

## Show time

```
$ v -o agent.js agent.v
$ v run main.v
ls: pid 66485
message received: {"type":"log","level":"info","payload":"Hello world"}
message received: {"type":"log","level":"info","payload":"frida message received"}
message received: {"type":"log","level":"info","payload":"frida message received"}
message received: {"type":"log","level":"info","payload":"frida message received"}
...
V panic: The connection is closed
$
```

## Running main demo

```
$ make
v -g main.v
./main
[>] frida: device-manager
[>] v: target
[>] frida: spawning
ls: pid 15709
[>] frida: loading script
[>] v: agent
loading
[main.v < agent.v]: Hello from the Agent side
[main.v < agent.v]: Symbol to hook found main__State_pull
[main.v < agent.v]: Stuff hooked
loaded
Count 666
Count 666
[main.v < agent.v]: pull method pwned
Count 666
[main.v < agent.v]: replace return value 666
Count 666
[main.v < agent.v]: pull method pwned
Count 666
[main.v < agent.v]: replace return value 666
Count 666
[main.v < agent.v]: pull method pwned
Count 666
Count 666
[main.v < agent.v]: replace return value 666
Count 666
[main.v < agent.v]: pull method pwned
Count 666
[main.v < agent.v]: replace return value 666
[main.v < agent.v]: pull method pwned
[main.v < agent.v]: replace return value 666
[main.v < agent.v]: pull method pwned
[>] frida: unloading the scene
unloaded
detached
```
