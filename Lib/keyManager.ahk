class KeyManager {
	isMasterHeld := false

	callback := ''
	lastPressed := 0

	sender := ''

	__New(masterKey, loopKey) {
		this.masterKey := masterKey
		this.loopKey := loopKey

		; Hotkey("~*" masterKey, (*) => manager.onMasterDown())
		; Hotkey("~*" masterKey " Up", (*) => manager.onMasterUp())
	}

	onMasterDown() {
		if this.isMasterHeld {
			; Suppress OS repeats if already held
			return
		}

		info("down " this.masterKey "/" this.loopKey)

		this.isMasterHeld := true
		this.doMasterDown()
	}

	doMasterDown() {
		PRESS_EVERY := 250
		HEALTH_CHECK := 25

		; Do master up first, to be safe
		this.doMasterUp()
		this.send()

		executeAt := this.lastPressed + PRESS_EVERY

		; Schedule subsequent work
		work(executeAt) {
			; Health check to force up event if needed
			if (this.healthCheck()) {
				; Abort and terminate if failed health check
				return
			}

			; Proceed to do down work, if appropriate
			if (A_TickCount >= executeAt) {
				; Do master up first, to be safe
				this.doMasterUp()
				this.send()

				executeAt := this.lastPressed + DELAY_LOOP
			}

			; Schedule subsequent work
			callback := () => work(executeAt)
			setTimeout(callback, Min(DELAY_HEARTBEAT, Max(1, executeAt - A_TickCount)), -2)
			this.callback := callback
		}
		callback := () => work(executeAt)
		setTimeout(callback, Min(HEALTH_CHECK, Max(1, executeAt - A_TickCount)), -2)
		this.callback := callback
	}

	onMasterUp() {
		info("UP " this.masterKey "/" this.loopKey)

		this.doMasterUp()
		this.isMasterHeld := false
	}

	doMasterUp() {
		; Clear existing work, if any
		if this.callback {
			clearTimeout(this.callback)
			this.callback := ''
		}

		; Clean up sender, if any
		if this.sender {
			this.sender.detonate()
			this.sender := ''
		}
	}

	healthCheck() {
		if !this.isMasterHeld || !GetKeyState(this.masterKey) {
			warn("FAKE TRIGGER:")
			this.onMasterUp()
			return true
		}
	}

	send() {
		if this.sender {
			; Sender could be stale, but we always detonate (possibly early).
			; The method should ignore late detonation if already done.
			this.sender.detonate()
			this.sender := ''
		}

		this.sender := Sender(this)
	}
}
