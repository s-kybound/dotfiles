import QtQuick
import Quickshell.Hyprland

// Workspace carousel: the active workspace stays fixed at the centre of
// the screen while the others slide around it.
Item {
    id: root
    clip: true

    property var screen: null

    readonly property var monitor: {
        Hyprland.monitors.values;
        return screen ? Hyprland.monitorFor(screen) : null;
    }

    readonly property var workspaces: monitor
        ? Hyprland.workspaces.values
            .filter(w => w.monitor === monitor)
            .sort((a, b) => a.id - b.id)
        : []

    Row {
        id: workspaceRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        readonly property int itemWidth: 12

        // centre-x of this monitor's active workspace within the row
        readonly property real activeCentre: {
            const list = root.workspaces
            const active = root.monitor ? root.monitor.activeWorkspace : null
            for (let i = 0; i < list.length; i++) {
                if (list[i] === active) {
                    // offset by the leading "[" bracket before the first workspace
                    return leftBracket.width + spacing
                         + i * (itemWidth + spacing) + itemWidth / 2
                }
            }
            return 0
        }

        // shift the row so the active workspace lands on screen centre
        x: parent.width / 2 - activeCentre
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        BarText { id: leftBracket; text: "[" }

        Repeater {
            model: root.workspaces
            delegate: Item {
                required property var modelData
                readonly property bool active: root.monitor
                                            && modelData === root.monitor.activeWorkspace
                width: workspaceRow.itemWidth
                height: label.implicitHeight

                BarText {
                    id: label
                    anchors.centerIn: parent
                    text: (active || mouse.containsMouse)
                          ? modelData.name
                          : "•"
                    font.underline: active
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
