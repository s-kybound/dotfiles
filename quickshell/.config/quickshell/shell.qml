import Quickshell
import QtQuick.Layouts

import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Networking

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: 30

    // all bar text shares one font
    component BarText: Text {
        font.family: "Iosevka"
    }

    // status bar - use the text prepared in the services
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
//        spacing: 20

// left: battery and clock

        Item {
	    Layout.fillWidth: true
            Layout.fillHeight: true
	    Layout.preferredWidth: 1
	    Layout.minimumWidth: 0
	    Layout.alignment: Qt.AlignLeft
	    RowLayout {
	    	anchors.fill: parent
		BarText {
		    text: services.battery.get(batteryMouse.containsMouse)
		    MouseArea {
			id: batteryMouse
			anchors.fill: parent
			hoverEnabled: true
		    }
		}

		BarText { text: services.clock.get() }

		Item { Layout.fillWidth: true }
            }
        }

	// center: workspace carousel - the focused workspace stays fixed at the
	// centre of the screen while the others shift around it
	Item {
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Layout.preferredWidth: 1
	    Layout.minimumWidth: 0
	    Layout.alignment: Qt.AlignHCenter
	    clip: true

	    Row {
		id: workspaceRow
		anchors.verticalCenter: parent.verticalCenter
		spacing: 4

		readonly property int itemWidth: 12

		// centre-x of the focused workspace within the row
		function focusedCentre() {
		    const list = Hyprland.workspaces.values
		    for (let i = 0; i < list.length; i++) {
			if (list[i].focused) {
			    // offset by the leading "[" bracket before the first workspace
			    return leftBracket.width + spacing
			         + i * (itemWidth + spacing) + itemWidth / 2
			}
		    }
		    return 0
		}

		// shift the row so the focused workspace lands on screen centre
		x: parent.width / 2 - focusedCentre()
		Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

		BarText { id: leftBracket; text: "[" }

		Repeater {
		    model: Hyprland.workspaces
		    delegate: Item {
			required property var modelData
			width: workspaceRow.itemWidth
			height: label.implicitHeight

			BarText {
			    id: label
			    anchors.centerIn: parent
			    text: (modelData.focused || mouse.containsMouse)
				  ? modelData.name
				  : "•"
			    font.underline: modelData.focused
			}

			MouseArea {
			    id: mouse
			    anchors.fill: parent
			    hoverEnabled: true
			    onClicked: modelData.activate()
			    cursorShape: Qt.PointingHandCursor
			}
		    }
		}

		BarText { text: "]" }
	    }
	}

	// right: network and volume
	Item {
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    Layout.preferredWidth: 1
	    Layout.minimumWidth: 0
	    Layout.alignment: Qt.AlignRight
	    RowLayout {
	    	anchors.fill: parent
	    	Item { Layout.fillWidth: true }
	    	BarText { text: services.network.get() }
	    	BarText { text: services.audio.get() }
    	    }
        }
    }
    
    QtObject {
        id: services
	property var clock: clockService
	property var workspaces: workspacesService
        property var battery: batteryService
        property var audio: audioService
        property var network: networkService
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

	// bar segments shown on each side of the centred battery text
	readonly property int barsPerSide: 5

	function getTimeLeft(seconds) {
		function pad(n) {
			return n < 10 ? "0" + n : n
		}
		var hours = Math.floor(seconds / 3600)
		var minutes = Math.floor((seconds % 3600) / 60)
		return hours + ":" + pad(minutes)
	}
	function getBatteryStatus(showPower) {
		var device = UPower.displayDevice
		var percentage = (device.percentage * 100).toFixed(0)
		var timeToState = UPower.onBattery ? device.timeToEmpty : device.timeToFull
		var direction = UPower.onBattery ? "↓" : "↑"
		var timeString = timeToState > 0 ? getTimeLeft(timeToState) : "∞"

		// on hover, the duration field is replaced by the power draw
		var detail = showPower ? device.changeRate.toFixed(0) + "W" : timeString

		// pad each field to a fixed width so the readout never changes size
		var text = percentage.padStart(3) + "% "
		         + direction + " "
		         + detail.padStart(5)

		// charge level as a meter, with the text always centred between
		// an equal number of segments on each side
		var segments = batteryService.barsPerSide * 2
		var filled = Math.min(Math.round(device.percentage * segments), segments)
		var meter = "|".repeat(filled) + ":".repeat(segments - filled)
		var left = meter.slice(0, batteryService.barsPerSide)
		var right = meter.slice(batteryService.barsPerSide)
		return "[" + left + " " + text + " " + right + "]"
	}
	function get(showPower) {
		var device = UPower.displayDevice
		return device.isLaptopBattery
		? getBatteryStatus(showPower)
		: "[AC Power]"
        }
    }
    
    QtObject {
	id: audioService
	property var sink: Pipewire.defaultAudioSink
	property PwObjectTracker tracker: PwObjectTracker {
		objects: audioService.sink ? [audioService.sink] : []
	}

	// bar segments shown on each side of the centred volume percentage
	readonly property int barsPerSide: 5

	// pad a string to a fixed width with the slack split evenly each side
	function centre(s, width) {
	    const slack = Math.max(width - s.length, 0)
	    const left = Math.floor(slack / 2)
	    return " ".repeat(left) + s + " ".repeat(slack - left)
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
	    const text = centre(vol + "%", 4)

	    // over 100% the bars turn into exclamation marks as a warning
	    const fill = vol > 100 ? "!" : "|"
	    const segments = audioService.barsPerSide * 2
	    const filled = Math.min(Math.round(audio.volume * segments), segments)
	    const meter = fill.repeat(filled) + ":".repeat(segments - filled)
	    const left = meter.slice(0, audioService.barsPerSide)
	    const right = meter.slice(audioService.barsPerSide)
	    return "[" + left + " " + text + " " + right + "]"
        }
    }

    QtObject {
	id: networkService
	function get() {
	    const devices = Networking.devices.values
	    for (let i = 0; i < devices.length; i++) {
		const dev = devices[i]
		if (!dev.connected) {
		    continue
		}

		if (dev.type === DeviceType.Wifi) {
		    const nets = dev.networks.values
		    for (let j = 0; j < nets.length; j++) {
			if (nets[j].connected) {
			    return "[" + nets[j].name + "]"
			}
		    }
		    return "[Wi-Fi]"
		}

		if (dev.type === DeviceType.Wired) {
		    return "[Ethernet]"
		}
	    }
	    return "[Disconnected]"
        }
    }
}
