import frida.agent


fn on_message(mut stanza agent.Stanza, mut data agent.Data) {
	eprintln('message received! ${stanza.payload}')

	agent.recv(on_message)
}

fn JS.state_is_ready_on_leave(retval agent.Retval) {
	println('Hooked callback')
	retval.replace(voidptr(1))
}

fn hook_stuff() {
eprintln("HOOKING jeje")
	mods := JS.Process.enumerateModules()
eprintln('mods $mods')
for mod in mods {
eprintln('mode $mod.name')
	symbols := JS.Module.enumerateSymbols(mod)
eprintln("HOOKING $symbols")
	for sym in symbols {
eprintln('hook $sym.name')
		if sym.name == 'main__State_pull' {
	//	if sym.name == 'main__State_is_ready' {
			eprintln('Hooking symbol found')
			agent.interceptor_attach(sym.address, JS.eval('{ on_leave: JS.state_is_ready_on_leave }'))
			break
		}
//		eprintln('${sym.address} ${sym.name}')
	}
}
}
/*

fn hook_isready(addr Pointer) {
	.attach({
		on_leave: 'state_is_ready_on_leave'
	})
	agent.interceptor_attach(is_ready, JS.eval('{
		onLeave: state_is_ready_on_leave
	}'))
}
*/

fn entry() {
	println('Hello from the Agent side')
 	hook_stuff()
	println('Stuff hooked')
 	agent.recv(on_message)
}
entry()
