module host

type DeviceManager = voidptr

pub enum DeviceType {
	local = C.FRIDA_DEVICE_TYPE_LOCAL
	usb = C.FRIDA_DEVICE_TYPE_USB
	remote = C.FRIDA_DEVICE_TYPE_REMOTE
}

pub fn new_device_manager() DeviceManager {
	C.frida_init()
	return C.frida_device_manager_new()
}

pub fn (dm DeviceManager) get_device_by_type(dt DeviceType) ?Device {
	err := &GError{}
	res := C.frida_device_manager_get_device_by_type_sync(dm, dt, 0, 0, &err)
	if res == 0 && err != 0 {
		// err->message
		return error('failed to retrieve device')
	}
	return res
}
