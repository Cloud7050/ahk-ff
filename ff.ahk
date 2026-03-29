; Autoreplace any existing instance when script is run
#SingleInstance Force

; Allow holding multiple keys to not bust the limit (OS will spam, which we suppress)
A_HotkeyInterval := 1000
A_MaxHotkeysPerInterval := 1000

; Attempt to improve event reliability
#MaxThreadsPerHotkey 10
#MaxThreads 50
ProcessSetPriority("High")

class KeyManager {
	isMasterHeld := false

	callback := ''
	sender := ''

	__New(masterKey, loopKey) {
		this.masterKey := masterKey
		this.loopKey := loopKey
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

		; Schedule subsequent work
		work(executeAt) {
			; Health check to force up event if needed
			if (this.healthCheck()) {
				; Abort and terminate if failed health check
				return
			}

			; Proceed to do down work, if appropriate
			if (A_TickCount >= executeAt) {
				executeAt := A_TickCount + PRESS_EVERY

				; Do master up first, to be safe
				this.doMasterUp()
				this.send()
			}

			; Schedule subsequent work
			callback := () => work(executeAt)
			setTimeout(callback, Min(HEALTH_CHECK, executeAt - A_TickCount))
			this.callback := callback
		}
		executeAt := A_TickCount + PRESS_EVERY
		callback := () => work(executeAt)
		setTimeout(callback, Min(HEALTH_CHECK, executeAt - A_TickCount))
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
	}

	healthCheck() {
		if this.isMasterHeld && !GetKeyState(this.masterKey) {
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
		}

		this.sender := Sender(this.loopKey)
	}
}

class Sender {
	__New(key) {
		this.key := key

		; Down now
		this.down()

		; Schedule up
		HOLD_FOR := 75

		this.callback := () => this.detonate()
		setTimeout(this.callback, HOLD_FOR)
	}

	down() {
		info("send " this.key)
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

; Utility functions
setTimeout(callback, delay) {
	SetTimer(callback, -delay)
}
clearTimeout(timer) {
	SetTimer(timer, 0)
}

; Debug log functions
info(message) {
	OutputDebug(A_TickCount " [INF] " message "`n")
}
warn(message) {
	OutputDebug(A_TickCount " [WRN] " message "`n")
}



; Main
register(masterKey, loopKey) {
	manager := KeyManager(masterKey, loopKey)
	Hotkey("~*" masterKey, (*) => manager.onMasterDown())
	Hotkey("~*" masterKey " Up", (*) => manager.onMasterUp())
}
; Pair of key down/up functions to delegate each key event to its respective KeyManager
; managerMap := Map()
; onKeyDown(eventName, masterKey) {
; 	if masterMap.Has(masterKey) {
; 		manager := managerMap.Get(masterKey)
; 		manager.onMasterDown()
; 	} else {
; 		warn("Hotkey " eventName " registered but no manager found!")
; 	}
; }
; onKeyUp(eventName, masterKey) {
; 	if masterMap.Has(masterKey) {
; 		manager := managerMap.Get(masterKey)
; 		manager.onMasterUp()
; 	} else {
; 		warn("Hotkey " eventName " registered but no manager found!")
; 	}
; }
register("F13", "p")
register("F14", "[")
register("F15", "]")
register("F16", "F4")
register("F17", "F5")
register("F18", "F6")
register("F19", "F7")
register("F20", "F8")
register("F21", "F9")
register("F22", "F10")
register("F23", "F11")
register("F24", "F12")
