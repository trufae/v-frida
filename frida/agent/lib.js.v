module agent

struct Module {
pub:
	name string
}

struct Symbol {
pub:
	address string
	name    string
	library string
	@type   string
	//	@isGlobal bool
}

// type Callback = fn(mut stanza Stanza, mut data Data) bool
type Callback = fn (mut Stanza, mut Data)

type Handler = voidptr
type Pointer = voidptr

fn JS.ptr(s string) any
fn JS.Process.enumerateModules() ?[]Module
fn JS.Module.findExportByName(moduleName string, exportName string) any
fn JS.Interceptor.attach(address Pointer, callback AttachCallback) Handler
fn JS.Interceptor.flush()
fn JS.Module.enumerateSymbols(mod Module) ?[]Symbol

pub struct AttachOptions {
	on_enter string // OnEnterCallback
	on_leave string // OnLeaveCallback
}

pub fn (p Pointer) attach(ao AttachOptions) Handler {
	mut code := ''
	if ao.on_enter != voidptr(0) {
		code += 'onEnter: $ao.on_enter'
	}
	if ao.on_leave != voidptr(0) {
		code += 'onLeave: $ao.on_leave'
	}
	return JS.Interceptor.attach(p, JS.eval('{$code}'))
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

type OnEnterCallback = fn (args voidptr)

type OnLeaveCallback = fn (retval Retval)

struct FunctionPointerType {
	name string
}

type FunctionPointer = voidptr

pub struct InterceptorOptions {
	on_enter FunctionPointerType // string // OnEnterCallback
	on_leave FunctionPointerType // string // OnLeaveCallback
}

pub fn interceptor_attach(address string, ao InterceptorOptions) Handler {
	//
	mut code := ''
	if JS.eval('typeof ao.on_enter') != 'undefined' {
		code += 'onEnter: $ao.on_enter.name'
	}
	if JS.eval('typeof ao.on_leave') != 'undefined' {
		code += 'onLeave: $ao.on_leave.name'
	}
	mut k := JS.eval('{$code}')
	return JS.Interceptor.attach(JS.ptr(address), k)
}

pub fn find_export_by_name(name string) ?Pointer {
	return JS.Module.findExportByName('', name)
}

pub fn new_pointer(a string) Pointer {
	return JS.ptr(a)
}

pub fn (p Pointer) new_native_function(ret string, args []string) {
}
