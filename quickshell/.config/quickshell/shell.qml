import Quickshell
import QtQuick
import QtQuick.Layouts

// Top bar: each segment lives in its own component file in this directory.
PanelWindow {
    anchors { top: true; left: true; right: true }
    implicitHeight: 30

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        // left: clock and network
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignLeft
            RowLayout {
                anchors.fill: parent
                Clock {}
                Network {}
                Item { Layout.fillWidth: true }
            }
        }

        // center: workspace carousel
        Workspaces {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignHCenter
        }

        // right: volume and battery
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignRight
            RowLayout {
                anchors.fill: parent
                Item { Layout.fillWidth: true }
                VolumeMeter {}
                Battery {}
            }
        }
    }
}
