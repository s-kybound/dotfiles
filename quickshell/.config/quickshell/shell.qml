import Quickshell

ShellRoot {
    id: root

    // Pin the full bar to the main monitor so it doesn't end up on whichever
    // screen Qt happens to pick first - e.g. the rotated side monitor, where a
    // "top" bar reads as a side bar.
    //
    // Matched on model rather than connector name: the DP/HDMI port names
    // shift around between boots, which silently dropped the bar onto the
    // wrong screen. Mirrors the desc: matching in hypr/hyprland.lua.
    readonly property var masterScreen: {
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

    Variants {
        model: Quickshell.screens

        Bar {
            master: modelData === root.masterScreen
        }
    }
}
