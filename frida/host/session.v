module host

type Session = voidptr

pub struct ScriptOptions {
	name string
	runtime ScriptRuntime
}

pub enum ScriptRuntime {
	qjs = C.FRIDA_SCRIPT_RUNTIME_QJS
	q8 = C.FRIDA_SCRIPT_RUNTIME_V8
}


pub fn (s Session)create_script(code string, options ScriptOptions) ?Script {
	e := voidptr(0)
/*
	opt := C.frida_script_options_new()
	C.frida_script_options_set_name(opt, 'name'.str))
	C.frida_script_options_set_runtime(opt, C.FRIDA_SCRIPT_RUNTIME_QJS)
*/
	opt := voidptr(0)
	script := C.frida_session_create_script_sync(s, code.str, opt, 0, &e)
	if e != 0 {
		return error('Cannot load script')
	}
	return script
}

pub enum SessionDetachReason {
	application_requested = C.FRIDA_SESSION_DETACH_REASON_APPLICATION_REQUESTED
	process_replaced = C.FRIDA_SESSION_DETACH_REASON_PROCESS_REPLACED
	process_terminated = C.FRIDA_SESSION_DETACH_REASON_PROCESS_TERMINATED
	server_terminated = C.FRIDA_SESSION_DETACH_REASON_SERVER_TERMINATED
	device_lost = C.FRIDA_SESSION_DETACH_REASON_DEVICE_LOST
}

type SessionDetachCallback = fn(s voidptr, reason SessionDetachReason, crash voidptr, user_data voidptr)

pub fn (s Session)on_detached(cb SessionDetachCallback, user_data voidptr) {
	C.g_signal_connect(s, 'detached', cb, user_data)
}

