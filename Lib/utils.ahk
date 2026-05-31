;;; Constants

; How often KeyManager should poll for heartbeat
DELAY_HEARTBEAT := 25

; How often WorkerLoop should construct a new Sender
DELAY_LOOP := 250

; How long Sender should wait before releasing its key by default
DELAY_HOLD := 100

; Thread priorities

PRIORITY_SENDER := -1
PRIORITY_WORKER := -2
PRIORITY_KEY_MANAGER := -3

;;; Utility functions

setTimeout(callback, delay, priority := 0) {
	SetTimer(callback, -delay, priority)
}
clearTimeout(callback) {
	SetTimer(callback, 0)
}

;;; Debug log functions

info(message) {
	OutputDebug(A_TickCount " [INF] " message "`n")
}
warn(message) {
	OutputDebug(A_TickCount " [WRN] " message "`n")
}
