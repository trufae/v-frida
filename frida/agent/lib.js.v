module agent

struct Module {
pub:
	name string
	path string
	base u64
	size u64
}

struct Symbol {
pub:
	name    string
	address string
	library string
	@type   string
	//	@isGlobal bool
}

// type Callback = fn(mut stanza Stanza, mut data Data) bool
type Callback = fn (mut Stanza, mut Data)

type Handler = voidptr
type Pointer = voidptr

fn JS.ptr(s string) any
fn JS.Process.enumerateModulesSync() []Module
fn JS.Module.findExportByName(moduleName string, exportName string) any
fn JS.Interceptor.attach(address Pointer, callback InterceptorOptions) Handler
fn JS.Interceptor.flush()
fn JS.Module.enumerateSymbolsSync(module_name string) []Symbol
fn JS.Module.enumerateExportsSync(module_name string) []Symbol

type OnEnterCallback = fn (args voidptr)

type OnLeaveCallback = fn (retval Retval)

struct FunctionPointerType {
	name string
}

type FunctionPointer = voidptr

pub struct InterceptorOptions {
	on_enter string // OnEnterCallback
	on_leave string // OnLeaveCallback
}

pub struct Stanza {
pub:
	payload string
}

pub struct Data {
}

fn JS.recv(callback Callback) bool
fn JS.send(message string, payload string)

pub fn recv(callback Callback) {
	// JS.console.log('frida message received')
	JS.recv(callback)
}

pub fn send(message string, payload string) {
	JS.send(message, payload)
}

type Retval = voidptr

pub fn (rv Retval) replace(res voidptr) {
	println('REAPLACE')
	#$rv.replace(res)
}

pub fn interceptor_attach(addr string, ao InterceptorOptions) Handler {
	//
	mut code := '{'
	if ao.on_enter != '' {
		code += 'onEnter: main__$ao.on_enter'
	}
	if ao.on_leave != '' {
		if ao.on_enter != '' {
			code += ','
		}
		code += 'onLeave: main__$ao.on_leave'
	}
	code += '}'
	eprintln('ATTACH $code')
	return JS.Interceptor.attach(JS.ptr(addr), JS.eval(code))
}

pub fn find_export_by_name(name string) ?Pointer {
	return JS.Module.findExportByName('', name)
}

pub fn new_pointer(a string) Pointer {
	return JS.ptr(a)
}

pub fn (p Pointer) new_native_function(ret string, args []string) {
}
