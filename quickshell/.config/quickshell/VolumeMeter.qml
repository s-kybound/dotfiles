import QtQuick
import Quickshell.Services.Pipewire

// Clickable volume meter: each bar sets the volume to that level and the
// centred number toggles mute. Renders as a row of single-character cells
// so individual bars can be clicked.
Row {
    id: root
    spacing: 0

    // bar segments shown on each side of the centred percentage
    readonly property int barsPerSide: 5
    property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // pad a string to a fixed width with the slack split evenly each side
    function centre(s, width) {
        const slack = Math.max(width - s.length, 0)
        const left = Math.floor(slack / 2)
        return " ".repeat(left) + s + " ".repeat(slack - left)
    }

    // set the volume to a 0..1 fraction, unmuting first
    function setVolume(value) {
        if (root.sink && root.sink.audio) {
            root.sink.audio.muted = false
            root.sink.audio.volume = value
        }
    }

    function toggleMute() {
        if (root.sink && root.sink.audio) {
            root.sink.audio.muted = !root.sink.audio.muted
        }
    }

    // run the action carried by a clicked meter cell
    function act(cell) {
        if (cell.action === "volume") {
            setVolume(cell.value)
        } else if (cell.action === "mute") {
            toggleMute()
        }
    }

    // the meter as a list of {text, action, value} cells; cells with an
    // action are clickable ("volume" sets that level, "mute" toggles mute)
    function cells() {
        const sink = root.sink
        if (!Pipewire.ready || !sink || !sink.audio) {
            return [{ text: "[N/A]", action: "", value: 0 }]
        }

        const audio = sink.audio
        if (audio.muted) {
            // same width as a full meter: "MUTE" (4 chars, like "100%") sits
            // centred where the percentage would, with spaces for the bars
            const pad = " ".repeat(root.barsPerSide + 1)
            return [
                { text: "[", action: "", value: 0 },
                { text: pad, action: "", value: 0 },
                { text: "MUTE", action: "mute", value: 0 },
                { text: pad, action: "", value: 0 },
                { text: "]", action: "", value: 0 },
            ]
        }

        const vol = Math.round(audio.volume * 100)
        const number = centre(vol + "%", 4)
        const fill = vol > 100 ? "!" : "█"
        const segments = root.barsPerSide * 2
        const filled = Math.min(Math.round(audio.volume * segments), segments)

        const out = [{ text: "[", action: "", value: 0 }]
        for (let i = 0; i < segments; i++) {
            out.push({ text: i < filled ? fill : "░", action: "volume", value: (i + 1) / segments })
            if (i === root.barsPerSide - 1) {
                out.push({ text: " ", action: "", value: 0 })
                for (const c of number) {
                    out.push({ text: c, action: "mute", value: 0 })
                }
                out.push({ text: " ", action: "", value: 0 })
            }
        }
        out.push({ text: "]", action: "", value: 0 })
        return out
    }

    Repeater {
        model: root.cells()
        delegate: BarText {
            required property var modelData
            text: modelData.text
            MouseArea {
                anchors.fill: parent
                enabled: modelData.action !== ""
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.act(modelData)
            }
        }
    }
}
