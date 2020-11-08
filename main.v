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

