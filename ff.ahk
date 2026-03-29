; Autoreplace any existing instance when script is run
#SingleInstance Force

; Allow holding multiple keys to not bust the limit (OS will spam, which we suppress)
A_HotkeyInterval := 1000
A_MaxHotkeysPerInterval := 1000

; Attempt to improve event reliability
#MaxThreadsPerHotkey 5
#MaxThreads 30
InstallKeybdHook()
ProcessSetPriority("High")

; Pair of key down/up helper functions to suppress OS repeated keydowns, and to monitor virtual held state
masterMap := Map()
keyDownSuppression(masterKey) {
	global masterMap

	if masterMap.Has(masterKey) {
		return true
	}
	masterMap[masterKey] := true
}
keyUpSuppression(masterKey) {
	global masterMap

	uDeleteKey(masterMap, masterKey)
}
unstuckCheck(masterKey) {
	global masterMap

	if !GetKeyState(masterKey) {
		keyUpSuppression(masterKey)
		OutputDebug(A_TickCount . " STUCK: FAKE UP " . masterKey . "`n")

		return true
	}
}

workTimer := unset
workKey := unset
keyDown(masterKey, loopKey, pressEvery := 250, holdFor := 75) {
	global workTimer, workKey

	; Suppress OS repeats
	if keyDownSuppression(masterKey) {
		return
	}
	OutputDebug(A_TickCount . " down " . masterKey . "`n")

	work() {
		if (unstuckCheck(masterKey)) {
			return
		}

		; Proxy send now
		keyDownSend(loopKey, holdFor)

		; Clear existing timer, if any
		if IsSet(workTimer) {
			uCancelTimer(workTimer)
		}
		; Schedule loop
		function := () => work()
		SetTimer(function, -pressEvery)
		workTimer := function
		workKey := loopKey
	}
	work()
}
keyUp(masterKey, loopKey) {
	global workTimer, workKey

	OutputDebug(A_TickCount . " UP " . masterKey . "`n")

	; Clear existing timer, but only if it's your own
	if IsSet(workTimer) && workKey == loopKey {
		uCancelTimer(workTimer)
		workTimer := unset
		workKey := unset
	}

	; Cleanup for proxy send now
	keyUpSend(loopKey)

	; Cleanup for suppress OS repeats
	keyUpSuppression(masterKey)
}

; Pair of key up/down helper functions to safely proxy key sends with varying hold lengths
upTimer := unset
keyDownSend(key, delay) {
	global upTimer

	; Explicitly force other key up early, if needed
	keyUpSend()

	; Key down now
	Send("{Blind}{" . key . " down}")

	; Schedule key up
	function := () => Send("{Blind}{" . key . " up}")
	SetTimer(function, delay)
	upTimer := function
}
keyUpSend(key := unset) {
	global upTimer

	isForceDetonate := !IsSet(key)

	; Detonate existing timer, if any
	if isForceDetonate && IsSet(upTimer) {
		uCancelTimer(upTimer)
		; Trigger it now manually
		upTimer()
		upTimer := unset
	}
}

uCancelTimer(timer) {
	SetTimer(timer, 0)
}
uDeleteKey(map, key) {
	if map.Has(key) {
		map.Delete(key)
	}
}

register(masterKey, loopKey) {
	Hotkey("$~*" . masterKey, (*) => keyDown(masterKey, loopKey))
	Hotkey("$~*" . masterKey . " Up", (*) => keyUp(masterKey, loopKey))
}
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
