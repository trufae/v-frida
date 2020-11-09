import frida.host
import os

fn main() {
	code := os.read_file('agent.js')?
	dm := host.new_device_manager()
	// device := dm.get_device_by_type(.usb)?
	device := dm.get_device_by_type(.local)?
	pid := device.spawn('/usr/local/bin/r2', {
		argv: ['/usr/local/bin/r2']
	})?
	eprintln('ls: pid $pid')

	session := device.attach(pid)?
	session.on_detached(host.SessionDetachCallback(on_detached), voidptr(0))

	script := session.create_script(code, {
		name: 'v-frida'
	})?

	script.on_message(host.MessageCallback(on_message), voidptr(0))

	script.load()?
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
