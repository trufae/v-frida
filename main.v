import frida

const (
	code = $embed('agent.js')
)

fn main() {
	dm := frida.new_device_manager()
	device := dm.get_device_by_type_sync(frida.device_type_usb)?
	session := device.attach_sync(pid)?
	script := session.create_script_sync(code)?
	script.on_message(on_message)
	session.on_detached(on_detach)

	script.load_sync()?
}
