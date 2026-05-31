class Sender {
	__New(manager) {
		this.manager := manager
		this.key := manager.loopKey

		; Down now
		this.down()

		; Schedule up
		HOLD_FOR := 100

		this.callback := () => this.detonate()
		setTimeout(this.callback, HOLD_FOR, -1)
	}

	down() {
		info("send " this.key)

		this.manager.lastPressed := A_TickCount
		Send("{Blind}{" this.key " down}")
	}

	up() {
		Send("{Blind}{" this.key " up}")
	}

	detonate() {
		if this.callback {
			clearTimeout(this.callback)
			this.callback := ''

			this.up()
		}
	}
}
