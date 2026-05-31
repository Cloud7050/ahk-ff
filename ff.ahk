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
TraySetIcon("C:\Users\cloud\Documents\Cache\Media\Plane Clouds Square.ico")

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

		manager
		if !managers.HasKey(osKey) {
			manager := KeyManager(osKey, worker)
			managers[osKey] := manager
		} else {
			manager := managers[osKey]
		}

		manager.define(windows, worker)
	}
}

; Define defaults
defineForWindows('', [
	["F13", WorkerSimple("F5")],
	["F14", WorkerSimple("XButton1")], ; Back
	["F15", WorkerSimple("XButton2")], ; Forward
	["F16", WorkerApp("firefox.exe")],
	["F17", WorkerApp("ApplicatonFrameHost.exe")], ; To Do
	["F18", WorkerApp("explorer.exe")],
	["F19", WorkerApp("Discord.exe")],
	; ["F20", ''],
	; ["F21", ''],
	; ["F22", ''],
	; ["F23", ''],
	; ["F24", ''],
])

; Define FF
defineForWindows('ffxiv_dx11.exe', [
	["F13", WorkerLoop("p")],
	["F14", WorkerLoop("[")],
	["F15", WorkerLoop("]")],
	["F16", WorkerLoop("F4")],
	["F17", WorkerLoop("F5")],
	["F18", WorkerLoop("F6")],
	["F19", WorkerLoop("F7")],
	["F20", WorkerLoop("F8")],
	["F21", WorkerLoop("F9")],
	["F22", WorkerLoop("F10")],
	["F23", WorkerLoop("F11")],
	["F24", WorkerLoop("F12")],
])
