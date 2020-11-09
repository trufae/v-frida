import frida.agent


fn on_message(mut stanza agent.Stanza, mut data agent.Data) {
//	eprintln('message received! ${stanza.payload}')

	agent.recv(on_message)
}

fn state_is_ready_on_leave(retval agent.Retval) {
	println('Hooked callback')
	retval.replace(1)
}

fn hook_stuff() {
	symbols := JS.Module.enumerateSymbols('target')
	for sym in symbols {
		if sym.name == 'main__State_is_ready' {
			println('Hooking symbol found')
			agent.interceptor_attach(sym.address, {
				on_leave: agent.FunctionPointer(state_is_ready_on_leave)
			})
			break
		}
//		eprintln('${sym.address} ${sym.name}')
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

fn main() {
	println('Hello from the Agent side')
	hook_stuff()
	println('Stuff hooked')
	agent.recv(on_message)
}
