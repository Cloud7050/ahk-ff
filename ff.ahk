; Autoreplace any existing instance when script is run
#SingleInstance Force

; Allow holding multiple keys to not bust the limit (OS will spam, which we suppress)
A_HotkeyInterval := 1000
A_MaxHotkeysPerInterval := 1000

; Attempt to improve event reliability
#MaxThreadsPerHotkey 10
#MaxThreads 50
ProcessSetPriority("High")
Critical()

; Set custom tray icon
TraySetIcon("C:\Users\P1373637\Documents\Cache\zMedia\Plane Clouds Square.ico")

;;; Imports

#Include <keyManager>
#Include <workers>
#Include <sender>
#Include <utils>

;;; Main

managers := Map()
defineForWindows(windows, pairs) {
	for _, pair in pairs {
		osKey := pair[1]
		worker := pair[2]

		local manager
		if !managers.Has(osKey) {
			manager := KeyManager(osKey)
			managers[osKey] := manager
		} else {
			manager := managers[osKey]
		}

		manager.define(windows, worker)
	}
}

; Define defaults
defineForWindows([''], [
	["F13", WorkerSimple("F5")],
	["F14", WorkerSimple("XButton1")], ; Back
	["F15", WorkerSimple("XButton2")], ; Forward
	["F16", WorkerExe("firefox.exe")],
	["F17", WorkerApp("Microsoft To Do", A_ScriptDir "\Microsoft To Do.lnk")],
	["F18", WorkerApp(" - File Explorer", "explorer.exe")],
	["F19", WorkerExe("ms-teams.exe")],
	["F20", WorkerExe("Code.exe")],
	; ["F21", ''],
	; ["F22", ''],
	; ["F23", ''],
	; ["F24", ''],

	["AppsKey", WorkerLoop("WheelLeft", DELAY_LOOP_SCROLL, DELAY_HOLD_SCROLL)],
	["SC07E", WorkerLoop("WheelRight", DELAY_LOOP_SCROLL, DELAY_HOLD_SCROLL)],
])
