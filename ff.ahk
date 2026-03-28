; Autoreplace any existing instance when script is run
#SingleInstance Force

; Allow holding multiple keys to not bust the limit (OS will spam, which we suppress)
A_HotkeyInterval := 1000
A_MaxHotkeysPerInterval := 1000

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
failsafe(masterKey) {
	global masterMap

	; Return true if key is not considered held and we should terminate
	return !masterMap.Has(masterKey)
	; return !GetKeyState(masterKey)
}

loopMap := Map()
keyDown(masterKey, loopKey, pressEvery := 250, holdFor := 75) {
	global loopMap

	; Supress OS repeats
	if keyDownSuppression(masterKey) {
		return
	}

	work() {
		; Proxy send now
		if (failsafe(masterKey)) {
			return
		}
		keyDownSend(loopKey, holdFor)

		; Clear existing timer, if any
		if loopMap.Has(loopKey) {
			uCancelTimer(loopMap[loopKey])
		}
		; Schedule loop
		function := () => work()
		if (failsafe(masterKey)) {
			return
		}
		SetTimer(function, pressEvery)
		loopMap[loopKey] := function
	}
	work()
}
keyUp(masterKey, loopKey) {
	global loopMap

	; Clear existing timer, if any
	if loopMap.Has(loopKey) {
		uCancelTimer(loopMap[loopKey])
		loopMap.Delete(loopKey)
	}

	; Cleanup for proxy send now
	keyUpSend(loopKey)

	; Cleanup for supress OS repeats
	keyUpSuppression(masterKey)
}

; Pair of key up/down helper functions to safely proxy key sends with varying hold lengths
upMap := Map()
keyDownSend(key, delay) {
	global upMap

	; Key down now
	Send("{Blind}{" . key . " down}")

	; Clear existing timer, if any
	if upMap.Has(key) {
		uCancelTimer(upMap[key])
	}

	; Schedule key up
	function := () => Send("{Blind}{" . key . " up}")
	SetTimer(function, delay)
	upMap[key] := function
}
keyUpSend(key) {
	global upMap

	; Detonate existing timer, if any
	if upMap.Has(key) {
		function := upMap[key]
		uCancelTimer(upMap[key])
		; Trigger it now manually
		function()
		upMap.Delete(key)
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
	eventName := "$*" . masterKey
	Hotkey(eventName, (*) => keyDown(masterKey, loopKey))
	Hotkey(eventName . " Up", (*) => keyUp(masterKey, loopKey))
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
