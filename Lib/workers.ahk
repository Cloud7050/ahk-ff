;;; Imports

#Include <sender>

;;; Main

class Worker {
	this.manager := ''

	onStart() {
	}

	onEnd() {
	}

	Init(manager) {
		this.manager := manager
	}
}

class WorkerSimple extends Worker {
	__New(key) {
		this.key := key
	}

	onStart() {
		return Sender.down(this.key)
	}

	onEnd() {
		Sender.up(this.key)
	}
}

class WorkerApp extends Worker {
	__New(exe) {
		this.exe := exe
	}

	onStart() {
		if WinExist("ahk_exe " this.exe) {
			WinActivate("ahk_exe " this.exe)
		} else {
			Run(this.exe)
		}
	}
}

class WorkerLoop extends Worker {
	callback := ''
	sender := ''

	__New(key) {
		this.key := key
	}

	onStart() {
		this.reset()
		pressedAt := this.send()
		executeAt := pressedAt + DELAY_LOOP

		work(executeAt) {
			if (!this.manager.heartbeat()) {
				return
			}

			this.reset()
			pressedAt := this.send()
			executeAt := pressedAt + DELAY_LOOP

			callback := () => work(executeAt)
			setTimeout(callback, Max(1, executeAt - A_TickCount), PRIORITY_WORKER)
			this.callback := callback
		}
		callback := () => work(executeAt)
		setTimeout(callback, Max(1, executeAt - A_TickCount), PRIORITY_WORKER)
		this.callback := callback
	}

	onEnd() {
		this.reset()
	}

	reset() {
		if this.callback {
			callback := this.callback
			this.callback := ''
			clearTimeout(callback)
		}

		if this.sender {
			sender := this.sender
			this.sender := ''
			sender.onKill()
		}
	}

	send() {
		if this.sender {
			sender := this.sender
			this.sender := ''
			sender.onKill()
		}

		sender := Sender(this.key)
		pressedAt := sender.onInit()
		this.sender := sender

		return pressedAt
	}
}
