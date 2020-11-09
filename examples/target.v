import time

struct State {
mut:
	n int
}

pub fn (mut s State)pull() int {
	return s.n++
}

pub fn (s State)is_ready() bool {
	return s.n < 10
}

fn main() {
	mut s := State{}
	for s.is_ready() {
		n := s.pull()
		println('Count $n')
		time.sleep(1)
	}
}
