import frida.host
import term
import time
import os
import json

struct Message {
	payload string
}

struct FridaState {
pub mut:
	device   host.Device
	pid      int
	script   host.Script
	dt       host.DeviceType
	session  host.Session
	dm       host.DeviceManager
}

fn echo(a string) {
	println(term.yellow(a))
}

fn watchdog(fs &FridaState) ? {
	time.sleep(10 * 100000)
	echo('[>] frida: unloading the scene')
	fs.script.unload() ?
	fs.device.kill(fs.pid) ?
	exit(1)
}

fn (mut fs FridaState) load_agent(fname string) ? {
	echo('[>] frida: loading script')
	mut sname := fname
	if fname.ends_with('.v') {
		echo('[>] v: agent')
		if os.system('v -b js_freestanding -o ${fname}.js $fname') != 0 {
			return error('agent oops')
		}
		sname = '${fname}.js'
	}
	code := host.agent_v_header + os.read_file(sname) ?
	script := fs.session.create_script(code, host.ScriptOptions{
		name: 'v-frida'
		on_message: host.ScriptMessageCallback(on_message)
		user_data: 0
	}) ?

	script.load() or { println('failed to load the agent script') }
	fs.script = script
}

fn (mut fs FridaState) attach_by_name(appname string) ? {
	if fs.dt == .usb {
		fs.device = fs.dm.get_device_by_type(.usb) ?
	}
	fs.session = fs.device.attach(fs.pid) ?
}

fn (mut fs FridaState) spawn(src string) ? {
	exe := if src.ends_with('.v') {
		echo('[>] v: target')
		os.system('v $src')
		src.replace('.v', '')
	} else {
		src
	}
	fs.device = fs.dm.get_device_by_type(.local) ?
	echo('[>] frida: spawning')
	fs.pid = fs.device.spawn(exe, host.SpawnOptions{
		argv: [exe]
	}) ?
	eprintln('ls: pid $fs.pid')

	fs.session = fs.device.attach(fs.pid) ?
}

fn new_frida_state(dt host.DeviceType) &FridaState {
	mut fs := &FridaState{
		dt: dt
		dm: host.new_device_manager()
		pid: -1
	}
	return fs
}

fn main() {
	echo('[>] frida: device-manager')

	mut fs := new_frida_state(.usb)
	fs.spawn('examples/target.v') ?
	// fs.attach('Twitter') ?

	fs.load_agent('agent.v') ?

	fs.session.on_detached(host.SessionDetachCallback(on_detached), 0)

	fs.device.resume(fs.pid) ?
	fill := go watchdog(fs)
	fill.wait() or { eprintln('Oops: $err') }
}

// TODO. wrap this thing, and use generics to hold userdata like in vweb
fn on_message(s host.Script, raw_message charptr, data voidptr, user_data voidptr) {
	unsafe {
		txt := tos2(raw_message)
		msg := json.decode(Message, txt) or { return }
		println('[main.v < agent.v]: $msg.payload')
	}
}

fn on_detached(s host.Session, reason host.SessionDetachReason, crash voidptr, user_data voidptr) {
	println('detached')
}
