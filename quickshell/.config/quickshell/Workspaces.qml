import QtQuick
import Quickshell.Hyprland

// Workspace carousel: the focused workspace stays fixed at the centre of
// the screen while the others slide around it.
Item {
    id: root
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
