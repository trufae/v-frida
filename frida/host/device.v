module host

pub struct SpawnOptions {
	argv []string
}

type Device = voidptr

pub fn (d Device) attach(pid int) ?Session {
	e := voidptr(0)
	s := C.frida_device_attach_sync(d, pid, 0, &e)
	if e != 0 {
		return error('cannot attach')
	}
	return s
}

pub fn (d Device) resume(pid int) ? {
	e := voidptr(0)
	C.frida_device_resume_sync(d, pid, voidptr(0), &e)
}

pub fn (d Device) spawn(argv0 string, so SpawnOptions) ?int {
	err := voidptr(0)
	options := C.frida_spawn_options_new()
	// TODO: properly construct argv from V's []string
	// C.frida_spawn_options_set_argv(options, &so.argv, so.argv.len)
	pid := C.frida_device_spawn_sync(d, argv0.str, options, 0, &err)
	//
	C.g_object_unref(options)
	if pid == -1 {
		return error('Cannot spawn')
	}
	return pid
}

pub fn (d Device) kill(pid int) ? {
	e := voidptr(0)
	C.frida_device_kill_sync(d, pid, 0, &e)
	if e != 0 {
		return error('cannot kill')
	}
}
