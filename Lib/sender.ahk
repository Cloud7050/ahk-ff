;;; Imports

#Include <utils>

;;; Main

class Sender {
	callback := ''

	__New(key) {
		this.key := key
	}

	static down(key) {
		Send("{Blind}{" key " down}")
		info("        " A_TickCount " " key)
	}

	static up(key) {
		Send("{Blind}{" key " up}")
	}

	onInit() {
		Sender.down(this.key)

		callback := () => this.onKill()
		setTimeout(callback, DELAY_HOLD, PRIORITY_SENDER)
		this.callback := callback
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
