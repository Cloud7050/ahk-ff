;;; Imports

#Include <utils>

;;; Main

w := ["F13", "F14", "F15", "F16", "F17", "F18", "F19", "F20", "F21", "F22", "F23", "F24"]
; Keys we don't suppress, in an attempt to get more accurate key state. They do not interfere when allowed to pass through
WHITELIST := Map()
for _, key in w {
	; Act like a Set
	WHITELIST[key] := true
}

class KeyManager {
	workers := Map()
	activeWorker := ''

	isHeld := false
	callback := ''

	__New(osKey) {
		this.osKey := osKey

		passthrough := this.isWhitelisted() ? "~" : ""
		Hotkey(passthrough "*" osKey, (*) => this.onDown())
		Hotkey(passthrough "*" osKey " Up", (*) => this.onUp())
	}

	onDown() {
		if this.isHeld {
			return
		}
		this.isHeld := true

		info("down " this.osKey)
		this.doDown()
	}

	doDown() {
		ranAt := A_TickCount

		this.reset()

		worker := this.getWorker()
		if worker {
			worker.onStart()
		}
		this.activeWorker := worker

		helper(ranAt) {
			if (!this.heartbeat()) {
				return
			}

			nextAt := ranAt + DELAY_HEARTBEAT
			callback := () => helper(nextAt)
			setTimeout(callback, Max(1, nextAt - A_TickCount), PRIORITY_KEY_MANAGER)
			this.callback := callback
		}
		nextAt := ranAt + DELAY_HEARTBEAT
		callback := () => helper(nextAt)
		setTimeout(callback, Max(1, nextAt - A_TickCount), PRIORITY_KEY_MANAGER)
		this.callback := callback
	}

	onUp() {
		info("UP   " this.osKey)
		this.reset()
		this.isHeld := false
	}

	;TODO subscribe to switch

	heartbeat() {
		if !this.isHeld || !this.isPressed() {
			warn("MANUAL FIRE:")
			this.onUp()
			return false
		}

		return true
	}

	isWhitelisted() {
		return WHITELIST.Has(this.osKey)
	}

	isPressed() {
		; If not suppressed, logical state will suffice over physical state, which seems more accurate for us
		return this.isWhitelisted()
			? GetKeyState(this.osKey)
			: GetKeyState(this.osKey, "P")
	}

	define(windows, worker) {
		worker.Init(this)
		for _, window in windows {
			this.workers[window] := worker
		}
	}

	getWorker() {
		try {
			focusedExe := WinGetProcessName("A") ; aka ahk_exe in Window Spy
			if this.workers.Has(focusedExe) {
				return this.workers[focusedExe]
			}
		} catch TargetError as e {
			warn(e.Message e.Extra)
		}

		; Fallback to default worker, if any
		if this.workers.Has('') {
			return this.workers['']
		}

		return ''
	}

	reset() {
		if this.activeWorker {
			activeWorker := this.activeWorker
			this.activeWorker := ''
			activeWorker.onEnd()
		}

		if this.callback {
			callback := this.callback
			this.callback := ''
			clearTimeout(callback)
		}
	}
}
