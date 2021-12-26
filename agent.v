import frida.agent

fn on_message(mut stanza agent.Stanza, mut data agent.Data) {
	eprintln('message received! $stanza.payload')
	agent.recv(on_message)
}

fn hook_stuff() ? {
	eprintln('HOOKING jeje')
	mods := JS.Process.enumerateModules() or { return err }
	for mod in mods {
		symbols := JS.Module.enumerateSymbols(mod) ?
		for sym in symbols {
			if sym.name == 'main__State_pull' {
				//	if sym.name == 'main__State_is_ready' {
		//		eprintln('Hooking symbol found')
				agent.interceptor_attach(sym.address, JS.eval('{ on_leave: state_is_ready_on_leave }'))
				break
			}
			// eprintln('${sym.address} ${sym.name}')
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

fn state_is_ready_on_leave(retval agent.Retval) {
	println('Hooked callback')
	retval.replace(voidptr(1))
}

fn main() {
	println('Hello from the Agent side')
	hook_stuff() or { eprintln('oops $err') }
	println('Stuff hooked')
	agent.recv(on_message)
}
