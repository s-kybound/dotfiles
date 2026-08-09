import Quickshell
import QtQuick
import QtQuick.Layouts

// Top bar: each segment lives in its own component file in this directory.
PanelWindow {
    // Pin the bar to the main monitor so it doesn't end up on whichever screen
    // Qt happens to pick first - e.g. the rotated side monitor, where a "top"
    // bar reads as a side bar.
    //
    // Matched on model rather than connector name: the DP/HDMI port names
    // shift around between boots, which silently dropped the bar onto the
    // wrong screen. Mirrors the desc: matching in hypr/hyprland.lua.
    screen: {
        const preferred = [
            s => s.model === "Q27G4_WS",  // desktop: 27" 2K, the main display
            s => s.name === "eDP-1",      // laptop: built-in panel
        ];
        for (const matches of preferred) {
            const match = Quickshell.screens.find(matches);
            if (match) return match;
        }
        return Quickshell.screens[0];
    }

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
