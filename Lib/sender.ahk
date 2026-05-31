;;; Imports

#Include <utils>

;;; Main

class Sender {
	__New(key) {
		this.key := key
		this.callback := ''
	}

	onInit() {
		pressedAt := this.down()

		this.callback := () => this.onKill()
		setTimeout(this.callback, HOLD_FOR, PRIORITY_SENDER)

		return pressedAt
	}

	onKill() {
		if this.callback {
			clearTimeout(this.callback)
			this.callback := ''

			this.up()
		}
	}

	down() {
		info("send " this.key)
		Send("{Blind}{" this.key " down}")

		return A_TickCount
	}

	up() {
		Send("{Blind}{" this.key " up}")
	}
}
