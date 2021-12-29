import frida.agent

fn main() {
	println('Hello from the Agent side')
	hook_stuff()
	println('Stuff hooked')
	agent.recv(on_message)
}

fn on_message(mut stanza agent.Stanza, mut data agent.Data) {
	eprintln('unmessage received! $stanza.payload')
	agent.recv(on_message)
}

fn statepull_hook(retval agent.Retval) {
	println('METHOD INTERCEPTION WORKS')
	retval.replace(voidptr(1))
}

fn hook_stuff() {
	mods := JS.Process.enumerateModulesSync()
	for mod in mods {
		symbols := JS.Module.enumerateSymbolsSync(mod.name)
		for sym in symbols {
			if sym.name == 'main__State_pull' {
				eprintln('Symbol to hook found $sym.name')
				// JS.eval('{ on_leave: state_is_ready_on_leave }'))
				agent.interceptor_attach(sym.address, agent.InterceptorOptions{
					on_leave: 'statepull_hook'
				})
				return
			}
		}
	}
}
