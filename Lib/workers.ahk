;;; Imports

#Include <sender>

;;; Main

class Worker {
	onStart() {
	}

	onEnd() {
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
