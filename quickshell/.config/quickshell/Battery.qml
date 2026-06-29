import QtQuick
import Quickshell.Services.UPower

// Battery charge as a fixed-width meter with the text centred between an
// equal number of segments per side. Hovering swaps the remaining time
// for the current power draw.
BarText {
    id: root

    // bar segments shown on each side of the centred text
    readonly property int barsPerSide: 5

    text: {
        const device = UPower.displayDevice
        return device.isLaptopBattery
            ? root.status(device, hover.containsMouse)
            : "[AC Power]"
    }

    function timeLeft(seconds) {
        function pad(n) {
            return n < 10 ? "0" + n : n
        }
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        return hours + ":" + pad(minutes)
    }

    function status(device, showPower) {
        const percentage = (device.percentage * 100).toFixed(0)
        const timeToState = UPower.onBattery ? device.timeToEmpty : device.timeToFull
        const direction = UPower.onBattery ? "↓" : "↑"
        const timeString = timeToState > 0 ? timeLeft(timeToState) : "∞"

        // on hover, the duration field is replaced by the power draw
        const detail = showPower ? device.changeRate.toFixed(0) + "W" : timeString

        // pad each field to a fixed width so the readout never changes size
        const text = percentage.padStart(3) + "% "
                   + direction + " "
                   + detail.padStart(5)

        // charge level as a meter, text centred between equal sides
        const segments = root.barsPerSide * 2
        const filled = Math.min(Math.round(device.percentage * segments), segments)
        const meter = "█".repeat(filled) + "░".repeat(segments - filled)
        return "[" + meter.slice(0, root.barsPerSide) + " " + text + " "
                   + meter.slice(root.barsPerSide) + "]"
    }

    // the time/power field is 5 chars wide and starts after the bracket,
    // the left bars, a space, "NNN% ", the direction arrow and a space
    readonly property int detailColumn: barsPerSide + 9
    readonly property int detailWidth: 5
    readonly property real charUnit: text.length ? contentWidth / text.length : 0

    // hovering just the time field reveals the power draw in its place
    MouseArea {
        id: hover
        hoverEnabled: true
        height: parent.height
        x: root.charUnit * root.detailColumn
        width: root.charUnit * root.detailWidth
    }
}
