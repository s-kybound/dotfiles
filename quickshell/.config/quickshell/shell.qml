import Quickshell
import QtQuick.Layouts

import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire

PanelWindow {
    anchors { top: true; left: true; right: true }
    implicitHeight: 30

    // status bar - use the text prepared in the services
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
//        spacing: 20

// left: battery and workspaces

        Item {
	    Layout.fillWidth: true
            Layout.fillHeight: true
	    Layout.preferredWidth: 1
	    Layout.minimumWidth: 0
	    Layout.alignment: Qt.AlignLeft
	    RowLayout {
	    	anchors.fill: parent
		Text { text: services.battery.get() }

		// experimental: workspace list
		// refactor this out!!!
                RowLayout {
		    spacing : 4
		    Text { text: "[" }
		    Repeater {
            		model: Hyprland.workspaces

            		delegate: Text {
			    required property var modelData
 			    text : modelData.name
			    font.underline: modelData.focused

                	    MouseArea {
                    		anchors.fill: parent
                    		onClicked: modelData.activate()
                	    }
                    	}
    		    }
		    Text { text: "]" }
               }

		Item { Layout.fillWidth: true }
            }
        }

	// center: clock
	Item {
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Layout.preferredWidth: 1
	    Layout.minimumWidth: 0
	    Layout.alignment: Qt.AlignHCenter
	    RowLayout {
	 	anchors.fill: parent
		Item { Layout.fillWidth: true }
		Text { text: services.clock.get() }
		Item { Layout.fillWidth: true }
            }
        }

	// right: volume
	Item {
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Layout.preferredWidth: 1
	    Layout.minimumWidth: 0
	    Layout.alignment: Qt.AlignRight
	    RowLayout {
	    	anchors.fill: parent
	    	Item { Layout.fillWidth: true }
	    	Text { text: services.audio.get() }
    	    }
        }
    }
    
    QtObject {
        id: services
	property var clock: clockService
	property var workspaces: workspacesService
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
	property var sink: Pipewire.defaultAudioSink
	property PwObjectTracker tracker: PwObjectTracker {
		objects: audioService.sink ? [audioService.sink] : []
	}

	function get() {
	    const sink = audioService.sink
	    if (!Pipewire.ready || !sink || !sink.audio) {
		return "[N/A]"
	    }
	    
	    const audio = sink.audio
	    if (audio.muted) {
		return "[muted]"
	    }
	    
	    const vol = Math.round(audio.volume * 100)
	    if (vol > 100) {
		return "[!!! " + vol + "%]"
	    }
            return "[" + vol + "%]"
        }
    }
}
