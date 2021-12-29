module host

#flag -Iext/frida
#flag -Lext/frida
#flag -lfrida-core -lresolv -framework Foundation -lbsm -framework AppKit

#include <frida-core.h>

pub const agent_v_header = 'function require() {return {};};var process={stdout:{write:console.log}};'

type GQuark = int

// type GError = C.GError

struct GError {
	q       GQuark
	code    int
	message charptr
}

struct Process {
	pid int
}

fn C.g_signal_connect(s voidptr, a charptr, cb voidptr, u voidptr)

fn C.frida_device_manager_get_device_by_type_sync(dm DeviceManager, dt DeviceType, a voidptr, b voidptr, err &&GError) Device
fn C.frida_device_manager_new() DeviceManager
fn C.frida_init()
fn C.frida_device_spawn_sync(d Device, a charptr, o voidptr, u voidptr, err voidptr) int
fn C.frida_device_resume_sync(d Device, p int, c voidptr, e voidptr)
fn C.frida_device_kill_sync(d Device, pid int, c voidptr, e voidptr)
fn C.frida_device_attach_sync(d Device, pid int, c voidptr, e voidptr) Session

fn C.frida_script_eternalize_sync(s Script, a voidptr, b voidptr)

fn C.frida_session_create_script_sync(s Session, code byteptr, opt voidptr, c voidptr, e voidptr) Script
fn C.frida_spawn_options_new() voidptr
fn C.frida_spawn_options_set_argv(so voidptr, argv voidptr, argc int)
fn C.g_object_unref(p voidptr)

fn C.frida_script_load_sync(s Script, c voidptr, e &&GError)
fn C.frida_script_unload_sync(s Script, c voidptr, e &&GError)

// C.FRIDA_DEVICE_TYPE_LOCAL
