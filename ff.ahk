; Autoreplace any existing instance when script is run
#SingleInstance Force

; Allow holding multiple keys to not bust the limit (OS will spam, which we suppress)
A_HotkeyInterval := 1000
A_MaxHotkeysPerInterval := 1000

; Attempt to improve event reliability
#UseHook
InstallKeybdHook()
ProcessSetPriority("High")

; Pair of key down/up helper functions to suppress OS repeated keydowns, and to monitor virtual held state
register0 := false
register1 := false
register2 := false
register3 := false
register4 := false
register5 := false
register6 := false
register7 := false
register8 := false
register9 := false
register10 := false
register11 := false
keyDownSuppression(index) {
	global

	switch index {
		case 0:
			if register0 {
				return true
			}
			register0 := true
		case 1:
			if register1 {
				return true
			}
			register1 := true
		case 2:
			if register2 {
				return true
			}
			register2 := true
		case 3:
			if register3 {
				return true
			}
			register3 := true
		case 4:
			if register4 {
				return true
			}
			register4 := true
		case 5:
			if register5 {
				return true
			}
			register5 := true
		case 6:
			if register6 {
				return true
			}
			register6 := true
		case 7:
			if register7 {
				return true
			}
			register7 := true
		case 8:
			if register8 {
				return true
			}
			register8 := true
		case 9:
			if register9 {
				return true
			}
			register9 := true
		case 10:
			if register10 {
				return true
			}
			register10 := true
		case 11:
			if register11 {
				return true
			}
			register11 := true
		default:
			throw "Not enough registers for index " . index
	}
}
keyUpSuppression(index) {
	global

	switch index {
		case 0:
			register0 := false
		case 1:
			register1 := false
		case 2:
			register2 := false
		case 3:
			register3 := false
		case 4:
			register4 := false
		case 5:
			register5 := false
		case 6:
			register6 := false
		case 7:
			register7 := false
		case 8:
			register8 := false
		case 9:
			register9 := false
		case 10:
			register10 := false
		case 11:
			register11 := false
		default:
			throw "Not enough registers for index " . index
	}
}
failsafe(index) {
	global

	; Return true if key is not considered held and we should terminate
	switch index {
		case 0:
			return !register0
		case 1:
			return !register1
		case 2:
			return !register2
		case 3:
			return !register3
		case 4:
			return !register4
		case 5:
			return !register5
		case 6:
			return !register6
		case 7:
			return !register7
		case 8:
			return !register8
		case 9:
			return !register9
		case 10:
			return !register10
		case 11:
			return !register11
		default:
			throw "Not enough registers for index " . index
	}
}

loopMap := Map()
keyDown(index, loopKey, pressEvery := 250, holdFor := 75) {
	global loopMap

	; Supress OS repeats
	if keyDownSuppression(index) {
		return
	}

	OutputDebug(A_TickCount . " down " . index . "`n")

	work() {
		; Proxy send now
		if (failsafe(index)) {
			return
		}
		keyDownSend(loopKey, holdFor)

		; Clear existing timer, if any
		if loopMap.Has(loopKey) {
			uCancelTimer(loopMap[loopKey])
		}
		; Schedule loop
		function := () => work()
		if (failsafe(index)) {
			return
		}
		SetTimer(function, pressEvery)
		loopMap[loopKey] := function
	}
	work()
}
keyUp(index, loopKey) {
	global loopMap

	OutputDebug(A_TickCount . " UP " . index . "`n")

	; Clear existing timer, if any
	if loopMap.Has(loopKey) {
		uCancelTimer(loopMap[loopKey])
		loopMap.Delete(loopKey)
	}

	; Cleanup for proxy send now
	keyUpSend(loopKey)

	; Cleanup for supress OS repeats
	keyUpSuppression(index)
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
	static i := 0

	; Remember the index at time of call
	index := i

	Hotkey(masterKey, (*) => keyDown(index, loopKey))
	Hotkey(masterKey . " Up", (*) => keyUp(index, loopKey))
	Hotkey("+" . masterKey, (*) => keyDown(index, loopKey))
	Hotkey("+" . masterKey . " Up", (*) => keyUp(index, loopKey))
	Hotkey("!" . masterKey, (*) => keyDown(index, loopKey))
	Hotkey("!" . masterKey . " Up", (*) => keyUp(index, loopKey))
	Hotkey("^" . masterKey, (*) => keyDown(index, loopKey))
	Hotkey("^" . masterKey . " Up", (*) => keyUp(index, loopKey))

	i++
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
