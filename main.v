import frida.host
import term
import time
import os

fn echo(a string) {
	println(term.yellow(a))
}

fn main() {
	echo('[>] v: target')
	os.system('v examples/target.v')
	echo('[>] v: agent')
	os.system('v -o agent.js agent.v')

	echo('[>] frida: device-manager')
	// select target device and process
	dm := host.new_device_manager()
	// device := dm.get_device_by_type(.usb)?
	device := dm.get_device_by_type(.local)?
	echo('[>] frida: spawning')
	pid := device.spawn('examples/target', {
		argv: ['examples/target']
	})?
	eprintln('ls: pid $pid')
	session := device.attach(pid)?
	session.on_detached(host.SessionDetachCallback(on_detached), voidptr(0))

	echo('[>] frida: loading script')
	// load agent code
	code := os.read_file('agent.js')?
	script := session.create_script(code, {
		name: 'v-frida'
		on_message: host.ScriptMessageCallback(on_message)
		user_data: voidptr(0)
	})?

	script.load()?
	echo('[>] frida: unloading the scene')
	device.resume(pid)
	time.sleep(10)
	script.unload()?
	device.kill(pid)
}

// TODO. wrap this thing, and use generics to hold userdata like in vweb
fn on_message(s host.Script, raw_message charptr, data voidptr, user_data voidptr) {
	msg := tos_clone(raw_message)
	println('message received: $msg')
}

fn on_detached(s host.Session, reason host.SessionDetachReason, crash voidptr, user_data voidptr) {
	println('detached')
}
