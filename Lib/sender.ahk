;;; Imports

#Include <utils>

;;; Main

class Sender {
	this.callback := ''

	__New(key) {
		this.key := key
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

		callback := () => this.onKill()
		setTimeout(callback, DELAY_HOLD, PRIORITY_SENDER)
		this.callback := callback

		return pressedAt
	}

	onKill() {
		if this.callback {
			callback := this.callback
			this.callback := ''
			clearTimeout(callback)

			Sender.up(this.key)
		}
	}
}
