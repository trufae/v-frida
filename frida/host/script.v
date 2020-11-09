module host

type Script = voidptr

pub fn (s Script)load() ? {
	e := voidptr(0)
	C.frida_script_load_sync(s, 0, &e)
	if e != 0 {
		return error('Cannot load script')
	}
}

pub fn (s Script)unload() ? {
	e := voidptr(0)
	C.frida_script_unload_sync(s, 0, &e)
	if e != 0 {
		return error('Cannot load script')
	}
}
