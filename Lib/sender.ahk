;;; Imports

#Include <utils>

;;; Main

class Sender {
	__New(key) {
		this.key := key
		this.callback := ''
	}

	static down(key) {
		info("send " key)
		Send("{Blind}{" key " down}")

		return A_TickCount
	}

	static up(key) {
		Send("{Blind}{" key " up}")
	}

	onInit() {
		pressedAt := Sender.down(this.key)

		this.callback := () => this.onKill()
		setTimeout(this.callback, HOLD_FOR, PRIORITY_SENDER)

		return pressedAt
	}

	onKill() {
		if this.callback {
			clearTimeout(this.callback)
			this.callback := ''

			Sender.up(this.key)
		}
	}
}
