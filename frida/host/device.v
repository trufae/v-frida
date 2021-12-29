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

pub fn (d Device) get_process_by_name(process_specifier string, err &&GError) ?Process {
	/*
	2         FridaProcess *process = frida_device_get_process_by_name_sync (
  3                 device, lo->process_specifier, 0, cancellable, &error);
  4         if (error != NULL) {
  5                 error = NULL;
  6                 char *procname = resolve_process_name_by_package_name(device, canc    ellable, lo->process_specifier);
  7                 if (procname) {
  8                         free (lo->process_specifier);
  9                         lo->process_specifier = procname;
 10                 }
 11                 process = frida_device_get_process_by_name_sync (
 12                 device, lo->process_specifier, 0, cancellable, &error);
 13         }
 14         if (error != NULL) {
 15                 if (!g_error_matches (error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) {
 16                         eprintf ("%s\n", error->message);
 17                 }
 18                 g_error_free (error);
 19                 return false;
 20         }
 21         lo->pid = frida_process_get_pid (process);
	*/
	return error('TODO')
}
