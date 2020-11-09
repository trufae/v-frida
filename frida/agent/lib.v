module agent

// type Callback = fn(mut stanza Stanza, mut data Data) bool
type Callback = voidptr

pub struct Stanza {
pub:
	payload string
}

pub struct Data {

}

fn JS.recv(callback Callback) bool
fn JS.send(message string, payload string)

pub fn recv(callback Callback) {
	JS.console.log('frida message received')
	JS.recv(callback)
}

pub fn send(message string, payload string) {
	JS.send(message, payload)
}
