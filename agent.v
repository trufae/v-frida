import frida.agent

fn on_message(mut stanza agent.Stanza, mut data agent.Data) {
	eprintln('message received! ${stanza.payload}')

	agent.recv(on_message)
}

fn main() {
	println('Hello world')
	agent.recv(on_message)
}
