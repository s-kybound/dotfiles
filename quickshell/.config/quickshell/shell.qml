import Quickshell
import Quickshell.Services.UPower
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
	function getTimeLeft(seconds) {
		function pad(n) {
			return n < 10 ? "0" + n : n
		}
		var hours = Math.floor(seconds / 3600)
		var minutes = Math.floor((seconds % 3600) / 60)
		return hours + ":" + pad(minutes)
	}
	function getBatteryStatus() {
		var device = UPower.displayDevice
		var percentage = (device.percentage * 100).toFixed(0)
		var timeToState = UPower.onBattery ? device.timeToEmpty : device.timeToFull
		var direction = UPower.onBattery ? "↓" : "↑"
		var powerDraw = UPower.onBattery 
		              ? " " + device.changeRate.toFixed(2) + "W" 
		              : "" 
		var timeString = timeToState > 0 ? getTimeLeft(timeToState) : "∞"
		return "[" + percentage + "% " + direction + " " + timeString + powerDraw + "]"
	}
	function get() {
		var device = UPower.displayDevice
		return device.isLaptopBattery
		? getBatteryStatus()
		: "[AC Power]"
        }
    }
    
    QtObject {
        id: audioService
        function get() {
            return "[TODO: audio]"
        }
    }
}
