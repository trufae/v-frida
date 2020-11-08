import frida

fn on_message(mut stanza frida.Stanza, mut data frida.Data) {
	eprintln('message received! ${stanza.payload}')

	frida.recv(on_message)
}

fn main() {
	println('Hello world')
	frida.recv(on_message)
}
