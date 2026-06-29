import QtQuick
import Quickshell

// Current time and date.
BarText {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    text: Qt.formatDateTime(clock.date, "[HH:mm • ddd dd/MM]")
}
