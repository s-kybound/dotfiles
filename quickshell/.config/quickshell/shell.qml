import Quickshell
import QtQuick

PanelWindow {
    anchors { top: true; left: true; right: true }
    implicitHeight: 30

    // status bar - use the text prepared in the services
    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 20

        // left: battery
        Text {
            text: services.battery.get()
        }

        // center: clock
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: services.clock.get()
        }

        // right: volume
        Text {
            anchors.right: parent.right
            text: services.audio.get()
        }
    }
    
    QtObject {
        id: services
        property var clock: clockService
        property var battery: batteryService
        property var audio: audioService
    }

    SystemClock { id: sysclock; precision: SystemClock.Minutes }
    QtObject {
        id: clockService
        function get() {
            return Qt.formatDateTime(sysclock.date, "[HH:mm • ddd dd/MM]")
        }
    }

    QtObject {
        id: batteryService
        function get() {
            return "[TODO: battery]"
        }
    }
    
    QtObject {
        id: audioService
        function get() {
            return "[TODO: audio]"
        }
    }
}
