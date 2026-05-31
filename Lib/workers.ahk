;;; Imports

#Include <sender>
#Include <utils>

;;; Main

class Worker {
	manager := ''

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
	__New(winTitle, toRun) {
		this.winTitle := winTitle
		this.toRun := toRun
	}

	onStart() {
		if WinExist(this.winTitle) {
			WinActivate(this.winTitle)
		} else {
			try {
				Run(this.toRun)
			} catch OSError as e {
				warn(e.Message e.Extra)
			}
		}
	}
}

class WorkerExe extends WorkerApp {
	__New(exe) {
		super.__New("ahk_exe " exe, exe)
	}
}

class WorkerLoop extends Worker {
	callback := ''
	sender := ''

	__New(key) {
		this.key := key
	}

	onStart() {
		pressedAt := A_TickCount

		this.reset()
		this.send()

		work(pressedAt) {
			if (!this.manager.heartbeat()) {
				return
			}

			this.reset()
			this.send()

			nextAt := pressedAt + DELAY_LOOP
			callback := () => work(nextAt)
			setTimeout(callback, Max(1, nextAt - A_TickCount), PRIORITY_WORKER)
			this.callback := callback
		}
		nextAt := pressedAt + DELAY_LOOP
		callback := () => work(nextAt)
		setTimeout(callback, Max(1, nextAt - A_TickCount), PRIORITY_WORKER)
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
			s := this.sender
			this.sender := ''
			s.onKill()
		}
	}

	send() {
		s := Sender(this.key)
		s.onInit()
		this.sender := s
	}
}
