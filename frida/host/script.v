module host

type Script = voidptr

pub fn (s Script)load() ? {
	e := &GError(0)
	println('loading')
	C.frida_script_load_sync(s, 0, &e)
	if e != 0 {
		unsafe {
			return error(tos2(e.message))
		}
	}
	println('loaded')
}

pub fn (s Script)unload() ? {
	e := &GError(0)
	C.frida_script_unload_sync(s, 0, &e)
	if e != 0 {
		unsafe {
			return error(tos2(e.message))
		}
	}
	println('unloaded')
}

pub fn (s Script)eternalize() {
	// C.frida_script_eternalize_sync(s, 0, 0)
}

type ScriptMessageCallback = fn(s voidptr, raw_message charptr, data voidptr, user_data voidptr)

pub fn (s Script)on_message(cb ScriptMessageCallback, u voidptr) {
	 C.g_signal_connect (s, c'message', cb, u)
}
