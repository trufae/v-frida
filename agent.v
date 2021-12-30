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

pub fn statepull_hook(retval agent.Retval) {
	println('pull method pwned')
	retval.replace(JS.Number(666))
}

fn hook_stuff() {
	mods := JS.Process.enumerateModulesSync()
	for mod in mods {
		symbols := JS.Module.enumerateSymbolsSync(mod.name)
		for sym in symbols {
			if sym.name == 'main__State_pull' {
				eprintln('Symbol to hook found $sym.name')
				agent.interceptor_attach(sym.address, agent.InterceptorOptions{
					on_leave: 'statepull_hook'
				})
				return
			}
		}
	}
}
