;;; Constants

; How long Sender should wait before releasing its key by default
HOLD_FOR := 100

; Sender thread priority
PRIORITY_SENDER := -1

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
