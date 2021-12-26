import frida.host
import term
import time
import os

fn echo(a string) {
	println(term.yellow(a))
}

fn fin(device host.Device, script host.Script, pid int) ? {
	time.sleep(10 * 100000)
	echo('[>] frida: unloading the scene')
	script.unload() ?
	device.kill(pid) ?
	exit(1)
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
	device := dm.get_device_by_type(.local) ?
	echo('[>] frida: spawning')
	pid := device.spawn('examples/target', host.SpawnOptions{
		argv: ['examples/target']
	}) ?
	eprintln('ls: pid $pid')
	session := device.attach(pid) ?
	session.on_detached(host.SessionDetachCallback(on_detached), 0)

	echo('[>] frida: loading script')
	// load agent code
	code := host.agent_v_header + os.read_file('agent.js') ?

	script := session.create_script(code, host.ScriptOptions{
		name: 'v-frida'
		on_message: host.ScriptMessageCallback(on_message)
		user_data: 0
	}) ?

	script.load() or { println('failed to load the agent script') }
	device.resume(pid) ?
	fill := go fin(device, script, pid)
	fill.wait() or { eprintln('Oops: $err') }
}

// TODO. wrap this thing, and use generics to hold userdata like in vweb
fn on_message(s host.Script, raw_message charptr, data voidptr, user_data voidptr) {
	println('MSGREV')
	unsafe {
		msg := tos2(raw_message)
		println('message received: $msg')
	}
}

fn on_detached(s host.Session, reason host.SessionDetachReason, crash voidptr, user_data voidptr) {
	println('detached')
}
