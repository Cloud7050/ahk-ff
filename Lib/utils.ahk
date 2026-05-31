; Utility functions
setTimeout(callback, delay, priority := 0) {
	SetTimer(callback, -delay, priority)
}
clearTimeout(callback) {
	SetTimer(callback, 0)
}

; Debug log functions
info(message) {
	OutputDebug(A_TickCount " [INF] " message "`n")
}
warn(message) {
	OutputDebug(A_TickCount " [WRN] " message "`n")
}
