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
	script := session.create_script(code, {
		name: 'v-frida'
	})?

	script.load()?
	script.unload()?
/*
	script.on_message(on_message)
	session.on_detached(on_detach)
*/
	device.kill(pid)
}
