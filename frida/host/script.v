module host

type Script = voidptr

fn C.frida_script_eternalize_sync(s Script, a voidptr, b voidptr)

pub fn (s Script)load() ? {
	e := &GError(0)
	C.frida_script_load_sync(s, 0, &e)
	if e != 0 {
		return error(tos_clone(e.message))
	}
}

pub fn (s Script)unload() ? {
	e := &GError(0)
	C.frida_script_unload_sync(s, 0, &e)
	if e != 0 {
		return error(tos_clone(e.message))
	}
}

pub fn (s Script)eternalize() {
	C.frida_script_eternalize_sync(s, 0, 0)
}

type MessageCallback = fn(s voidptr, raw_message charptr, data voidptr, user_data voidptr)

pub fn (s Script)on_message(cb MessageCallback, u voidptr) {
	C.g_signal_connect (s, 'message', cb, u)
}
